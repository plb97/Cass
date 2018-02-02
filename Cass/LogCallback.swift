//
//  LogCallback.swift
//  Cass
//
//  Created by Philippe on 28/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

public typealias LogCallbackFunction = (LogCallbackData) -> ()
public struct LogCallback {
    fileprivate let function: LogCallbackFunction
    fileprivate let data_ptr_: UnsafeMutableRawPointer?
    private var ptr_: UnsafeMutableRawPointer?
    public init<T>(function: @escaping LogCallbackFunction, data data_: T? = nil) {
        self.function = function
        self.data_ptr_ = allocPointer(data_)
        self.ptr_ = nil
        ptr_ = allocPointer(self)
        cass_log_set_callback(default_log_callback, ptr_!)
    }
    public func deallocData<T>(as _ : T.Type) {
        deallocPointer(data_ptr_, as: T.self)
        deallocPointer(ptr_!, as: LogCallback.self)
        cass_log_set_callback(nil, nil)
    }
    public func data<T>(as _: T.Type) -> T? {
        if let data = data_ptr_ {
            return pointee(data, as: T.self)
        } else {
            return nil
        }
    }
}
public struct LogCallbackData {
    public let callback: LogCallback
    public let logMessage: LogMessage
    fileprivate init(log_message: CassLogMessage, callback: LogCallback) {
        self.callback = callback
        self.logMessage = LogMessage(log_message)
    }
}
func default_log_callback(_ log_message_: UnsafePointer<CassLogMessage>?,_ data_: UnsafeMutableRawPointer?) {
    if let log_message = log_message_?.pointee, let data = data_ {
        let callback = pointee(data, as: LogCallback.self)
        callback.function(LogCallbackData(log_message: log_message, callback: callback))
    } else {
        fatalError(FATAL_ERROR_MESSAGE)
    }
}

