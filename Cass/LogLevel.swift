//
//  LogLevel.swift
//  Cass
//
//  Created by Philippe on 16/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

public enum LogLevel: CustomStringConvertible {
    case disabled
    case critical
    case error
    case warn
    case info
    case debug
    case trace
    init(_ cass: CassLogLevel) {
        self = LogLevel.fromCass(cass)
    }
    public var description: String {
        switch self {
        case .disabled:
            return "CASS_LOG_DISABLED"
        case .critical:
            return "CASS_LOG_CRITICAL"
        case .error:
            return "CASS_LOG_ERROR"
        case .warn:
            return "CASS_LOG_WARN"
        case .info:
            return "CASS_LOG_INFO"
        case .debug:
            return "CASS_LOG_DEBUG"
        case .trace:
            return "CASS_LOG_TRACE"
        }
    }
    var cass: CassLogLevel {
        switch self {
        case .disabled:
            return CASS_LOG_DISABLED
        case .critical:
            return CASS_LOG_CRITICAL
        case .error:
            return CASS_LOG_ERROR
        case .warn:
            return CASS_LOG_WARN
        case .info:
            return CASS_LOG_INFO
        case .debug:
            return CASS_LOG_DEBUG
        case .trace:
            return CASS_LOG_TRACE
        }
    }
    private static func fromCass(_ cass: CassLogLevel) -> LogLevel {
        switch cass {
        case CASS_LOG_DISABLED:
            return .disabled
        case CASS_LOG_CRITICAL:
            return .critical
        case CASS_LOG_ERROR:
            return .error
        case CASS_LOG_WARN:
            return .warn
        case CASS_LOG_INFO:
            return .info
        case CASS_LOG_DEBUG:
            return .debug
        case CASS_LOG_TRACE:
            return .trace
        default:
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
}


extension CassLogLevel: CustomStringConvertible {
    public var description: String {
        if let str = String(validatingUTF8: cass_log_level_string(self)) {
            return str
        } else {
            fatalError(FATAL_ERROR_MESSAGE) // ne devrait pas se produire
        }
    }
}

