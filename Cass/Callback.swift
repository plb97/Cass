//
//  Callback.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public typealias CallbackFunction = (CallbackData) -> ()
public struct Callback {
    fileprivate let function: CallbackFunction
    fileprivate let data_ptr_: UnsafeMutableRawPointer?
    private var ptr_: UnsafeMutableRawPointer?
    public init<T>(callback: @escaping CallbackFunction, data data_: T? = nil) {
        self.function = callback
        self.data_ptr_ = allocPointer(data_)
        self.ptr_ = nil
        ptr_ = allocPointer(self)
    }
    func setCallback(future: OpaquePointer) {
        cass_future_set_callback(future, default_callback, ptr_)
    }
    public func deallocData<T>(as: T.Type) {
        deallocPointer(data_ptr_, as: T.self)
        deallocPointer(ptr_, as: Callback.self)
    }
    public func data<T>(as _: T.Type) -> T? {
        if let data = data_ptr_ {
            return pointee(data, as: T.self)
        } else {
            return nil
        }
    }
}
public struct CallbackData {
    public let callback: Callback
    public let future: Future
    fileprivate init(future: OpaquePointer, callback: Callback) {
        self.callback = callback
        self.future = Future(future)
    }
}
fileprivate func default_callback(future_: OpaquePointer?, data_: UnsafeMutableRawPointer?) {
    if let data = data_ {
        let callback = pointee(data, as: Callback.self)
        if let future = future_ {
            callback.function(CallbackData(future: future, callback: callback))
        }
    } else {
        fatalError(FATAL_ERROR_MESSAGE)
    }
}
