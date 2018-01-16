//
//  WriteType.swift
//  Cass
//
//  Created by Philippe on 16/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

public enum WriteType: CustomStringConvertible {
    case unknown
    case simple
    case batch
    case unloggedBatch
    case counter
    case batchLog
    case cas
    case view
    case cdc
    init(_ cass: CassWriteType) {
        self = WriteType.fromCass(cass)
    }
    public var description: String {
        switch self {
        case .unknown:
            return "CASS_WRITE_TYPE_UNKNOWN"
        case .simple:
            return "CASS_WRITE_TYPE_SIMPLE"
        case .batch:
            return "CASS_WRITE_TYPE_BATCH"
        case .unloggedBatch:
            return "CASS_WRITE_TYPE_UNLOGGED_BATCH"
        case .counter:
            return "CASS_WRITE_TYPE_COUNTER"
        case .batchLog:
            return "CASS_WRITE_TYPE_BATCH_LOG"
        case .cas:
            return "CASS_WRITE_TYPE_CAS"
        case .view:
            return "CASS_WRITE_TYPE_VIEW"
        case .cdc:
            return "CASS_WRITE_TYPE_CDC"
        }
    }
    var cass: CassWriteType {
        switch self {
        case .unknown:
            return CASS_WRITE_TYPE_UNKNOWN
        case .simple:
            return CASS_WRITE_TYPE_SIMPLE
        case .batch:
            return CASS_WRITE_TYPE_BATCH
        case .unloggedBatch:
            return CASS_WRITE_TYPE_UNLOGGED_BATCH
        case .counter:
            return CASS_WRITE_TYPE_COUNTER
        case .batchLog:
            return CASS_WRITE_TYPE_BATCH_LOG
        case .cas:
            return CASS_WRITE_TYPE_CAS
        case .view:
            return CASS_WRITE_TYPE_VIEW
        case .cdc:
            return CASS_WRITE_TYPE_CDC
        }
    }
    private static func fromCass(_ cass: CassWriteType) -> WriteType {
        switch cass {
        case CASS_WRITE_TYPE_SIMPLE:
            return .simple
        case CASS_WRITE_TYPE_BATCH:
            return .batch
        case CASS_WRITE_TYPE_UNLOGGED_BATCH:
            return .unloggedBatch
        case CASS_WRITE_TYPE_COUNTER:
            return .counter
        case CASS_WRITE_TYPE_BATCH_LOG:
            return .batchLog
        case  CASS_WRITE_TYPE_CAS:
            return.cas
        case CASS_WRITE_TYPE_VIEW:
            return .view
        case CASS_WRITE_TYPE_CDC:
            return .cdc
        default:
            return .unknown
        }
    }
}

extension CassWriteType: CustomStringConvertible {
    public var description: String {
        if let str = String(validatingUTF8: cass_write_type_string(self)) {
            return str
        } else {
            fatalError(FATAL_ERROR_MESSAGE) // ne devrait pas se produire
        }
    }
}


