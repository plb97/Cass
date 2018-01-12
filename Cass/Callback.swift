//
//  Callback.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

fileprivate func toPointer<T>(_ p_: T?) -> UnsafeMutableRawPointer? {
    if let p = p_ {
        let ptr = UnsafeMutableRawPointer.allocate(bytes: MemoryLayout<T>.stride, alignedTo:MemoryLayout<T>.alignment)
        ptr.storeBytes(of: p, as: type(of: p))
        return ptr
    }
    return nil
}

public struct CallbackData {
    private let data_: UnsafeMutableRawPointer?
    private let ftrp : OpaquePointer
    public let future: Future
    fileprivate init(future ftrp: OpaquePointer, data data_: UnsafeMutableRawPointer? = nil) {
        self.ftrp  = ftrp
        self.data_ = data_
        self.future = Future(ftrp)
    }
    public var dataPointer: UnsafeMutableRawPointer? { return self.data_ }
}
public typealias CallbackFunction = (CallbackData) -> ()

public struct Callback {
    static func setCallback(future: OpaquePointer, callback: Callback) {
        cass_future_set_callback(future, default_callback, toPointer(callback))
    }
    fileprivate let callback: CallbackFunction
    fileprivate let data_: UnsafeMutableRawPointer?
    public init<T>(callback: @escaping CallbackFunction, data p_: T? = nil) {
        self.callback = callback
        self.data_ = toPointer(p_)
    }
}

//fileprivate typealias callback_t = @convention(c) (OpaquePointer?, UnsafeMutableRawPointer?) -> ()
fileprivate func default_callback(future_: OpaquePointer?, data_: UnsafeMutableRawPointer?) -> () {
    if let data = data_ {
        let callback = data.bindMemory(to: Callback.self, capacity: 1).pointee
        defer {
            data.deallocate(bytes: MemoryLayout<Callback>.stride, alignedTo: MemoryLayout<Callback>.alignment)
        }
        if let future = future_ {
            callback.callback(CallbackData(future: future, data: callback.data_))
        }
    } else {
        fatalError("Ne devrait pas arriver")
    }
}
