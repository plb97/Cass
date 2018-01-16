//
//  ProtocolVersion.swift
//  Cass
//
//  Created by Philippe on 16/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

public enum ProtocolVersion: CustomStringConvertible {
    case v1
    case v2
    case v3
    case v4
    case v5
    init(_ cass: CassProtocolVersion) {
        self = ProtocolVersion.fromCass(cass)
    }
    public var description: String {
        switch self {
        case .v1:
            return "CASS_PROTOCOL_VERSION_V1"
        case .v2:
            return "CASS_PROTOCOL_VERSION_V2"
        case .v3:
            return "CASS_PROTOCOL_VERSION_V3"
        case .v4:
            return "CASS_PROTOCOL_VERSION_V4"
        case .v5:
            return "CASS_PROTOCOL_VERSION_V5"
        }
    }
    var cass: CassProtocolVersion {
        switch self {
        case .v1:
            return CASS_PROTOCOL_VERSION_V1
        case .v2:
            return CASS_PROTOCOL_VERSION_V2
        case .v3:
            return CASS_PROTOCOL_VERSION_V3
        case .v4:
            return CASS_PROTOCOL_VERSION_V4
        case .v5:
            return CASS_PROTOCOL_VERSION_V5
        }
    }
    private static func fromCass(_ cass: CassProtocolVersion) -> ProtocolVersion {
        switch cass {
        case CASS_PROTOCOL_VERSION_V1:
            return .v1
        case CASS_PROTOCOL_VERSION_V2:
            return .v2
        case CASS_PROTOCOL_VERSION_V3:
            return .v3
        case CASS_PROTOCOL_VERSION_V4:
            return .v4
        case CASS_PROTOCOL_VERSION_V5:
            return .v5
        default:
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
}

extension CassProtocolVersion: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_PROTOCOL_VERSION_V1:
            return "CASS_PROTOCOL_VERSION_V1"
        case CASS_PROTOCOL_VERSION_V2:
            return "CASS_PROTOCOL_VERSION_V2"
        case CASS_PROTOCOL_VERSION_V3:
            return "CASS_PROTOCOL_VERSION_V3"
        case CASS_PROTOCOL_VERSION_V4:
            return "CASS_PROTOCOL_VERSION_V4"
        case CASS_PROTOCOL_VERSION_V5:
            return "CASS_PROTOCOL_VERSION_V5"
        default:
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
}
