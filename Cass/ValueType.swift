//
//  ValueType.swift
//  Cass
//
//  Created by Philippe on 15/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

public enum ValueType: CustomStringConvertible {
    case unknown
    case custom
    case ascii
    case bigint
    case blob
    case boolean
    case counter
    case decimal
    case double
    case float
    case int
    case text
    case timestamp
    case uuid
    case varchar
    case varint
    case timeuuid
    case inet
    case date
    case time
    case smallint
    case tinyint
    case duration
    case list
    case map
    case set
    case udt
    case tuple
    init(_ cass: CassValueType) {
        self = ValueType.fromCass(cass)
    }
    public var description: String {
        switch self {
        case .unknown: return "CASS_VALUE_TYPE_UNKNOWN"
        case .custom: return "CASS_VALUE_TYPE_CUSTOM"
        case .ascii: return "CASS_VALUE_TYPE_ASCII"
        case .bigint: return "CASS_VALUE_TYPE_BIGINT"
        case .blob: return "CASS_VALUE_TYPE_BLOB"
        case .boolean: return "CASS_VALUE_TYPE_BOOLEAN"
        case .counter: return "CASS_VALUE_TYPE_COUNTER"
        case .decimal: return "CASS_VALUE_TYPE_DECIMAL"
        case .double: return "CASS_VALUE_TYPE_DOUBLE"
        case .float: return "CASS_VALUE_TYPE_FLOAT"
        case .int: return "CASS_VALUE_TYPE_INT"
        case .text: return "CASS_VALUE_TYPE_TEXT"
        case .timestamp: return "CASS_VALUE_TYPE_TIMESTAMP"
        case .uuid: return "CASS_VALUE_TYPE_UUID"
        case .varchar: return "CASS_VALUE_TYPE_VARCHAR"
        case .varint: return "CASS_VALUE_TYPE_VARINT"
        case .timeuuid: return "CASS_VALUE_TYPE_TIMEUUID"
        case .inet: return "CASS_VALUE_TYPE_INET"
        case .date: return "CASS_VALUE_TYPE_DATE"
        case .time: return "CASS_VALUE_TYPE_TIME"
        case .smallint: return "CASS_VALUE_TYPE_SMALL_INT"
        case .tinyint: return "CASS_VALUE_TYPE_TINY_INT"
        case .duration: return "CASS_VALUE_TYPE_DURATION"
        case .list: return "CASS_VALUE_TYPE_LIST"
        case .map: return "CASS_VALUE_TYPE_MAP"
        case .set: return "CASS_VALUE_TYPE_SET"
        case .udt: return "CASS_VALUE_TYPE_UDT"
        case .tuple: return "CASS_VALUE_TYPE_TUPLE"
        }
    }

    var cass: CassValueType {
        switch self {
        case .unknown: return CASS_VALUE_TYPE_UNKNOWN
        case .custom: return CASS_VALUE_TYPE_CUSTOM
        case .ascii: return CASS_VALUE_TYPE_ASCII
        case .bigint: return CASS_VALUE_TYPE_BIGINT
        case .blob: return CASS_VALUE_TYPE_BLOB
        case .boolean: return CASS_VALUE_TYPE_BOOLEAN
        case .counter: return CASS_VALUE_TYPE_COUNTER
        case .decimal: return CASS_VALUE_TYPE_DECIMAL
        case .double: return CASS_VALUE_TYPE_DOUBLE
        case .float: return CASS_VALUE_TYPE_FLOAT
        case .int: return CASS_VALUE_TYPE_INT
        case .text: return CASS_VALUE_TYPE_TEXT
        case .timestamp: return CASS_VALUE_TYPE_TIMESTAMP
        case .uuid: return CASS_VALUE_TYPE_UUID
        case .varchar: return CASS_VALUE_TYPE_VARCHAR
        case .varint: return CASS_VALUE_TYPE_VARINT
        case .timeuuid: return CASS_VALUE_TYPE_TIMEUUID
        case .inet: return CASS_VALUE_TYPE_INET
        case .date: return CASS_VALUE_TYPE_DATE
        case .time: return CASS_VALUE_TYPE_TIME
        case .smallint: return CASS_VALUE_TYPE_SMALL_INT
        case .tinyint: return CASS_VALUE_TYPE_TINY_INT
        case .duration: return CASS_VALUE_TYPE_DURATION
        case .list: return CASS_VALUE_TYPE_LIST
        case .map: return CASS_VALUE_TYPE_MAP
        case .set: return CASS_VALUE_TYPE_SET
        case .udt: return CASS_VALUE_TYPE_UDT
        case .tuple: return CASS_VALUE_TYPE_TUPLE
        }
    }
    private static func fromCass(_ cass: CassValueType) -> ValueType {
        switch cass {
        case CASS_VALUE_TYPE_CUSTOM: return .custom
        case CASS_VALUE_TYPE_ASCII: return .ascii
        case CASS_VALUE_TYPE_BIGINT: return .bigint
        case CASS_VALUE_TYPE_BLOB: return .blob
        case CASS_VALUE_TYPE_BOOLEAN: return .boolean
        case CASS_VALUE_TYPE_COUNTER: return .counter
        case CASS_VALUE_TYPE_DECIMAL: return .decimal
        case CASS_VALUE_TYPE_DOUBLE: return .double
        case CASS_VALUE_TYPE_FLOAT: return .float
        case CASS_VALUE_TYPE_INT: return .int
        case CASS_VALUE_TYPE_TEXT: return .text
        case CASS_VALUE_TYPE_TIMESTAMP: return .timestamp
        case CASS_VALUE_TYPE_UUID: return .uuid
        case CASS_VALUE_TYPE_VARCHAR: return varchar
        case CASS_VALUE_TYPE_VARINT: return .varint
        case CASS_VALUE_TYPE_TIMEUUID: return .timeuuid
        case CASS_VALUE_TYPE_INET: return .inet
        case CASS_VALUE_TYPE_DATE: return .date
        case CASS_VALUE_TYPE_TIME: return .time
        case CASS_VALUE_TYPE_SMALL_INT: return .smallint
        case CASS_VALUE_TYPE_TINY_INT: return .tinyint
        case CASS_VALUE_TYPE_DURATION: return .duration
        case CASS_VALUE_TYPE_LIST: return .list
        case CASS_VALUE_TYPE_MAP: return .map
        case CASS_VALUE_TYPE_SET: return .set
        case CASS_VALUE_TYPE_UDT: return .udt
        case CASS_VALUE_TYPE_TUPLE: return .tuple
        default: return .unknown
        }
    }
}

extension CassValueType: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_VALUE_TYPE_UNKNOWN: return "CASS_VALUE_TYPE_UNKNOWN"
        case CASS_VALUE_TYPE_CUSTOM: return "CASS_VALUE_TYPE_CUSTOM"
        case CASS_VALUE_TYPE_ASCII: return "CASS_VALUE_TYPE_ASCII"
        case CASS_VALUE_TYPE_BIGINT: return "CASS_VALUE_TYPE_BIGINT"
        case CASS_VALUE_TYPE_BLOB: return "CASS_VALUE_TYPE_BLOB"
        case CASS_VALUE_TYPE_BOOLEAN: return "CASS_VALUE_TYPE_BOOLEAN"
        case CASS_VALUE_TYPE_COUNTER: return "CASS_VALUE_TYPE_COUNTER"
        case CASS_VALUE_TYPE_DECIMAL: return "CASS_VALUE_TYPE_DECIMAL"
        case CASS_VALUE_TYPE_DOUBLE: return "CASS_VALUE_TYPE_DOUBLE"
        case CASS_VALUE_TYPE_FLOAT: return "CASS_VALUE_TYPE_FLOAT"
        case CASS_VALUE_TYPE_INT: return "CASS_VALUE_TYPE_INT"
        case CASS_VALUE_TYPE_TEXT: return "CASS_VALUE_TYPE_TEXT"
        case CASS_VALUE_TYPE_TIMESTAMP: return "CASS_VALUE_TYPE_TIMESTAMP"
        case CASS_VALUE_TYPE_UUID: return "CASS_VALUE_TYPE_UUID"
        case CASS_VALUE_TYPE_VARCHAR: return "CASS_VALUE_TYPE_VARCHAR"
        case CASS_VALUE_TYPE_VARINT: return "CASS_VALUE_TYPE_VARINT"
        case CASS_VALUE_TYPE_TIMEUUID: return "CASS_VALUE_TYPE_TIMEUUID"
        case CASS_VALUE_TYPE_INET: return "CASS_VALUE_TYPE_INET"
        case CASS_VALUE_TYPE_DATE: return "CASS_VALUE_TYPE_DATE"
        case CASS_VALUE_TYPE_TIME: return "CASS_VALUE_TYPE_TIME"
        case CASS_VALUE_TYPE_SMALL_INT: return "CASS_VALUE_TYPE_SMALL_INT"
        case CASS_VALUE_TYPE_TINY_INT: return "CASS_VALUE_TYPE_TINY_INT"
        case CASS_VALUE_TYPE_DURATION: return "CASS_VALUE_TYPE_DURATION"
        case CASS_VALUE_TYPE_LIST: return "CASS_VALUE_TYPE_LIST"
        case CASS_VALUE_TYPE_MAP: return "CASS_VALUE_TYPE_MAP"
        case CASS_VALUE_TYPE_SET: return "CASS_VALUE_TYPE_SET"
        case CASS_VALUE_TYPE_UDT: return "CASS_VALUE_TYPE_UDT"
        case CASS_VALUE_TYPE_TUPLE: return "CASS_VALUE_TYPE_TUPLE"
        default: fatalError(FATAL_ERROR_MESSAGE)
        }
    }
}

