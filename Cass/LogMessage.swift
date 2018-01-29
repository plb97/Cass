//
//  LogMessage.swift
//  Cass
//
//  Created by Philippe on 26/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

public struct LogMessage: CustomStringConvertible {
    static public func setLevel(_ level: LogLevel = .warn) {
        cass_log_set_level(level.cass)
    }
    static public func setCallback(_ callback: LogCallback) -> UnsafeMutableRawPointer? {
        let ptr = allocPointer(callback)
        cass_log_set_callback(default_log_callback, ptr)
        return ptr
    }

    public let date: Date
    public let severity: LogLevel
    public let file: String
    public let line: Int
    public let function: String
    public let message: String
    init(_ log_message: CassLogMessage) {
        date = Date(timestamp: Int64(log_message.time_ms))
        severity = LogLevel(log_message.severity)
        file = String(validatingUTF8: log_message.file) ?? ""
        line = Int(log_message.line)
        function = String(validatingUTF8: log_message.function) ?? ""
        var msg = log_message.message
        message = String(ptr: &msg.0, len: MemoryLayout.size(ofValue: msg)) ?? ""
    }
    public var description: String {
        return "\(date) \(severity) \(file) \(line) \(function) \(message)"
    }
}
