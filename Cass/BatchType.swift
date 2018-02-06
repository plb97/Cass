//
//  BatchType.swift
//  Cass
//
//  Created by Philippe on 16/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

public enum BatchType: CustomStringConvertible {
    case logged
    case unlogged
    case counter
    init(_ cass: CassBatchType) {
        self = BatchType.fromCass(cass)
    }
    public var description: String {
        switch self {
        case .logged:
            return "CASS_BATCH_TYPE_LOGGED"
        case .unlogged:
            return "CASS_BATCH_TYPE_UNLOGGED"
        case .counter:
            return "CASS_BATCH_TYPE_COUNTER"
        }
    }
    var cass: CassBatchType {
        switch self {
        case .logged:
            return CASS_BATCH_TYPE_LOGGED
        case .unlogged:
            return CASS_BATCH_TYPE_UNLOGGED
        case .counter:
            return CASS_BATCH_TYPE_COUNTER
        }
    }
    private static func fromCass(_ cass: CassBatchType) -> BatchType {
        switch cass {
        case CASS_BATCH_TYPE_LOGGED:
            return .logged
        case CASS_BATCH_TYPE_UNLOGGED:
            return .unlogged
        case CASS_BATCH_TYPE_COUNTER:
            return .counter
        default:
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
}

extension CassBatchType: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_BATCH_TYPE_LOGGED:
            return "CASS_BATCH_TYPE_LOGGED"
        case CASS_BATCH_TYPE_UNLOGGED:
            return "CASS_BATCH_TYPE_UNLOGGED"
        case CASS_BATCH_TYPE_COUNTER:
            return "CASS_BATCH_TYPE_COUNTER"
        default:
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }


}
