//
//  Listener.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

fileprivate func toPointer<T>(_ p_: T?, as type: T.Type) -> UnsafeMutableRawPointer? {
    if let p = p_ {
        let ptr = UnsafeMutableRawPointer.allocate(bytes: MemoryLayout<T>.stride, alignedTo:MemoryLayout<T>.alignment)
        ptr.initializeMemory(as: type, to: p)
        return ptr
    } else {
        return nil
    }
}

public struct Listener_t {
    private let data_: UnsafeMutableRawPointer?
    private let ftrp : OpaquePointer
    public let future: Future
    fileprivate init(ftrp: OpaquePointer, data data_: UnsafeMutableRawPointer? = nil) {
        self.ftrp  = ftrp
        self.data_ = data_
        self.future = Future(ftrp)
    }
    public var dataPointer: UnsafeMutableRawPointer? { return self.data_ }
    // public lazy var future = { return Future(self.ftrp) }() // 'lazy' incompatible avec une structure utilisee avec 'let'
}

public typealias Listener_f = (Listener_t) -> ()
public struct Listener {
    public static func setCallback(future: OpaquePointer, listener: Listener) {
        print("@@@@ cass_future_set_callback(future, default_callback, data) \(future)")
        cass_future_set_callback(future, default_callback, toPointer(listener, as: Listener.self))
    }
    fileprivate let callback: Listener_f
    fileprivate let data_: UnsafeMutableRawPointer?
    public init<T>(callback: @escaping Listener_f, data p_: T? = nil) {
        self.callback = callback
        if let p = p_ {
            self.data_ = toPointer(p, as: type(of: p))
        } else {
            self.data_ = nil
        }
    }
}
fileprivate typealias callback_t = @convention(c) (OpaquePointer?, UnsafeMutableRawPointer?) -> ()
//@_silgen_name("default_callback")
fileprivate func default_callback(future_: OpaquePointer?, data_: UnsafeMutableRawPointer?) -> () {
    print("default_callback...")
    if let data = data_ {
        let listener = data.bindMemory(to: Listener.self, capacity: 1).pointee
        defer {
            data.deallocate(bytes: MemoryLayout<Listener>.stride, alignedTo: MemoryLayout<Listener>.alignment)
        }
        if let future = future_ {
            listener.callback(Listener_t(ftrp: future, data: listener.data_))
        }
    } else {
        fatalError("Ne devrait pas arriver")
    }
    print("...default_callback")
}

