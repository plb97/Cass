//
//  IndexType.swift
//  Cass
//
//  Created by Philippe on 15/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

public enum IndexType: CustomStringConvertible {
    case unknown
    case keys
    case custom
    case composites
    init(_ cass: CassIndexType) {
        self = IndexType.fromCass(cass)
    }
    public var description: String {
        switch self {
        case .unknown:
            return "CASS_INDEX_TYPE_UNKNOWN"
        case .keys:
            return "CASS_INDEX_TYPE_KEYS"
        case .custom:
            return "CASS_INDEX_TYPE_CUSTOM"
        case .composites:
            return "CASS_INDEX_TYPE_COMPOSITES"
        }
    }
    var cass: CassIndexType {
        switch self {
        case .unknown:
            return CASS_INDEX_TYPE_UNKNOWN
        case .keys:
            return CASS_INDEX_TYPE_KEYS
        case .custom:
            return CASS_INDEX_TYPE_CUSTOM
        case .composites:
            return CASS_INDEX_TYPE_COMPOSITES
        }
    }
    private static func fromCass(_ cass: CassIndexType) -> IndexType {
        switch cass {
        case CASS_INDEX_TYPE_KEYS:
            return .keys
        case CASS_INDEX_TYPE_CUSTOM:
            return .custom
        case CASS_INDEX_TYPE_COMPOSITES:
            return .composites
        default:
            return .unknown
        }
    }
}

extension CassIndexType: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_INDEX_TYPE_UNKNOWN: return "CASS_INDEX_TYPE_UNKNOWN"
        case CASS_INDEX_TYPE_KEYS: return "CASS_INDEX_TYPE_KEYS"
        case CASS_INDEX_TYPE_CUSTOM: return "CASS_INDEX_TYPE_CUSTOM"
        case CASS_INDEX_TYPE_COMPOSITES: return "CASS_INDEX_TYPE_COMPOSITES"
        default: fatalError(FATAL_ERROR_MESSAGE)
        }
    }
}

