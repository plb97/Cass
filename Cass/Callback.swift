//
//  Callback.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public typealias CallbackFunction = (CallbackData) -> ()
public struct Callback {
    static func setCallback(future: OpaquePointer, callback: Callback) {
        let callback_ptr_ = allocPointer(callback)
        cass_future_set_callback(future, default_callback, callback_ptr_)
    }
    fileprivate let function: CallbackFunction
    fileprivate let data_: UnsafeMutableRawPointer?
    public init<T>(callback: @escaping CallbackFunction, data p_: T? = nil) {
        self.function = callback
        self.data_ = allocPointer(p_)
    }
}
public struct CallbackData {
    private let callback_ptr: UnsafeMutableRawPointer
    private let data_: UnsafeMutableRawPointer?
    public let future: Future
    fileprivate init(future ftrp: OpaquePointer, ptr : UnsafeMutableRawPointer, data data_: UnsafeMutableRawPointer? = nil) {
        self.callback_ptr = ptr
        self.data_ = data_
        self.future = Future(ftrp)
    }
    public func data<T>(as _: T.Type) -> T? {
        if let data = data_ {
            return pointee(data, as: T.self)
        } else {
            return nil
        }
    }
    public func dealloc<T>(_ : T.Type) {
        deallocPointer(data_, as: T.self)
        deallocPointer(callback_ptr, as: Callback.self)
    }
}
fileprivate func default_callback(future_: OpaquePointer?, data_: UnsafeMutableRawPointer?) -> () {
    if let data = data_ {
        let callback = pointee(data, as: Callback.self)
        if let future = future_ {
            callback.function(CallbackData(future: future, ptr: data_!, data: callback.data_))
        }
    } else {
        fatalError(FATAL_ERROR_MESSAGE)
    }
}
