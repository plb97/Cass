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
    static public func setLevel(_ level: LogLevel = .warn) {
        cass_log_set_level(level.cass)
    }
    static public func setCallback(_ callback: LogCallback) -> UnsafeMutableRawPointer? {
        print("setCallback")
        let ptr = allocPointer(callback)
        cass_log_set_callback(default_log_callback, ptr)
        return ptr
    }
    fileprivate let function: LogCallbackFunction
    fileprivate let data_: UnsafeMutableRawPointer?
    public init<T>(callback: @escaping LogCallbackFunction, data data_: T? = nil) {
        self.function = callback
        print("LogCallback init")
        self.data_ = allocPointer(data_)
    }
    public func free<T>(_ ptr_: UnsafeMutableRawPointer?, as type: T) {
        deallocPointer(data_, as: type)
        deallocPointer(ptr_, as: LogCallback.self)
    }
}
public struct LogCallbackData {
    private let data_: UnsafeMutableRawPointer?
    public let logMessage: LogMessage
    fileprivate init(log_message: CassLogMessage, data data_: UnsafeMutableRawPointer? = nil) {
        self.data_ = data_
        self.logMessage = LogMessage(log_message)
    }
    public func data<T>(as type: T.Type) -> T? {
        return data_?.bindMemory(to: type, capacity: 1).pointee
    }
    public func free<T>(as type: T) {
        deallocPointer(data_, as: type)
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

