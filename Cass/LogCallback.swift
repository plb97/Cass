//
//  LogCallback.swift
//  Cass
//
//  Created by Philippe on 28/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

import Dispatch

public typealias LogCallbackFunction = (LogCallbackData) -> ()
public struct LogCallback {
    fileprivate let function: LogCallbackFunction
    fileprivate let data_: UnsafeMutableRawPointer?
    public init<T>(function: @escaping LogCallbackFunction, data data_: T? = nil) {
        self.function = function
        print("LogCallback init")
        self.data_ = allocPointer(data_)
    }
    public func dealloc<T>(_ log_callback_ptr: UnsafeMutableRawPointer?,as _ : T.Type) {
        deallocPointer(data_, as: T.self)
        deallocPointer(log_callback_ptr, as: LogCallback.self)
    }
}
public struct LogCallbackData {
    private let data_: UnsafeMutableRawPointer?
    public let logMessage: LogMessage
    fileprivate init(log_message: CassLogMessage, data data_: UnsafeMutableRawPointer? = nil) {
        self.data_ = data_
        self.logMessage = LogMessage(log_message)
    }
    public func data<T>(as _: T.Type) -> T? {
        return pointee(data_, as: T.self)
    }
}
func default_log_callback(_ log_message_: UnsafePointer<CassLogMessage>?,_ data_: UnsafeMutableRawPointer?) {
    if let log_message = log_message_?.pointee {
        if let callback = data_?.bindMemory(to: LogCallback.self, capacity: 1).pointee {
            callback.function(LogCallbackData(log_message: log_message, data: callback.data_))
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
}

