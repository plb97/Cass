//
//  ErrorSource.swift
//  Cass
//
//  Created by Philippe on 16/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

public enum ErrorSource: CustomStringConvertible {
    case none
    case lib
    case server
    case ssl
    init(_ cass: CassErrorSource) {
        self = ErrorSource.fromCass(cass)
    }
    case compression
    public var description: String {
        switch self {
        case .none:
            return "CASS_ERROR_SOURCE_NONE"
        case .lib:
            return "CASS_ERROR_SOURCE_LIB"
        case .server:
            return "CASS_ERROR_SOURCE_SERVER"
        case .ssl:
            return "CASS_ERROR_SOURCE_SSL"
        case .compression:
            return "CASS_ERROR_SOURCE_COMPRESSION"
        }
    }
    var cass: CassErrorSource {
        switch self {
        case .none:
            return CASS_ERROR_SOURCE_NONE
        case .lib:
            return CASS_ERROR_SOURCE_LIB
        case .server:
            return CASS_ERROR_SOURCE_SERVER
        case .ssl:
            return CASS_ERROR_SOURCE_SSL
        case .compression:
            return CASS_ERROR_SOURCE_COMPRESSION
        }
    }
    private static func fromCass(_ cass: CassErrorSource) -> ErrorSource {
        switch cass {
        case CASS_ERROR_SOURCE_NONE:
            return .none
        case CASS_ERROR_SOURCE_LIB:
            return .lib
        case CASS_ERROR_SOURCE_SERVER:
            return .server
        case CASS_ERROR_SOURCE_SSL:
            return .ssl
        case CASS_ERROR_SOURCE_COMPRESSION:
            return .compression
        default:
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
}

extension CassErrorSource: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_ERROR_SOURCE_NONE: return "CASS_ERROR_SOURCE_NONE"
        case CASS_ERROR_SOURCE_LIB: return "CASS_ERROR_SOURCE_LIB"
        case CASS_ERROR_SOURCE_SERVER: return "CASS_ERROR_SOURCE_SERVER"
        case CASS_ERROR_SOURCE_SSL: return "CASS_ERROR_SOURCE_SSL"
        case CASS_ERROR_SOURCE_COMPRESSION: return "CASS_ERROR_SOURCE_COMPRESSION"
        default: fatalError(FATAL_ERROR_MESSAGE)
        }
    }
}

