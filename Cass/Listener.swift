//
//  Listener.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

public class /*struct*/ Listener_t {
    private let data_: UnsafeMutableRawPointer?
    private let ftrp : OpaquePointer
    //public let future: Future
    fileprivate init(ftrp: OpaquePointer, data data_: UnsafeMutableRawPointer? = nil) {
        self.ftrp  = ftrp
        self.data_ = data_
    //    self.future = Future(ftrp)
    }
    public var dataPointer: UnsafeMutableRawPointer? { return self.data_ }
     public lazy var future = { return Future(self.ftrp) }() // 'lazy' incompatible avec une structure utilisee avec 'let'
}

fileprivate func toPointer<T>(_ p_: T?) -> UnsafeMutableRawPointer? {
    if let p = p_ {
        let ptr = UnsafeMutableRawPointer.allocate(bytes: MemoryLayout<T>.stride, alignedTo:MemoryLayout<T>.alignment)
        ptr.storeBytes(of: p, as: type(of: p))
        return ptr
    }
    return nil
}
public typealias Listener_f = (Listener_t) -> ()
public struct Listener {
    public static func setCallback(future: OpaquePointer, listener: Listener) {
        cass_future_set_callback(future, default_callback, toPointer(listener))
    }
    fileprivate let callback: Listener_f
    fileprivate let data_: UnsafeMutableRawPointer?
    public init<T>(callback: @escaping Listener_f, data p_: T? = nil) {
        self.callback = callback
        self.data_ = toPointer(p_)
    }
}

fileprivate typealias callback_t = @convention(c) (OpaquePointer?, UnsafeMutableRawPointer?) -> ()
//@_silgen_name("default_callback")
fileprivate func default_callback(future_: OpaquePointer?, data_: UnsafeMutableRawPointer?) -> () {
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
}
