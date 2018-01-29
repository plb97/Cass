//
//  Callback.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

public typealias CallbackFunction = (CallbackData) -> ()
public struct Callback {
    static func setCallback(future: OpaquePointer, callback: Callback) -> UnsafeMutableRawPointer? {
        let ptr_ = allocPointer(callback)
        cass_future_set_callback(future, default_callback, ptr_)
        return ptr_
    }
    fileprivate let function: CallbackFunction
    fileprivate let data_: UnsafeMutableRawPointer?
    public init<T>(callback: @escaping CallbackFunction, data p_: T? = nil) {
        self.function = callback
        self.data_ = allocPointer(p_)
    }
}
public struct CallbackData {
    private let data_: UnsafeMutableRawPointer?
    public let future: Future
    fileprivate init(future ftrp: OpaquePointer, data data_: UnsafeMutableRawPointer? = nil) {
        self.data_ = data_
        self.future = Future(ftrp)
    }
    public var hasData: Bool { return nil != data_ }
    public func data<T>(as type: T.Type) -> T? {
        return data_?.bindMemory(to: type, capacity: 1).pointee
    }
    public func free<T>(as type: T) {
        deallocPointer(data_, as: type)
    }
}
fileprivate func default_callback(future_: OpaquePointer?, data_: UnsafeMutableRawPointer?) -> () {
    defer {
        deallocPointer(data_, as: Callback.self)
    }
    if let callback = data_?.bindMemory(to: Callback.self, capacity: 1).pointee {
        if let future = future_ {
            callback.function(CallbackData(future: future, data: callback.data_))
        }
    } else {
        fatalError(FATAL_ERROR_MESSAGE)
    }
}
