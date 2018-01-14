//
//  Cass.swift
//  Cass
//
//  Created by Philippe on 19/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

import Foundation
public typealias BLOB = Array<UInt8>

// http://docs.datastax.com/en/developer/cpp-driver/2.7/

extension CassConsistency: CustomStringConvertible {
    public var description: String {
//        switch self {
//        case CASS_CONSISTENCY_UNKNOWN: return "CASS_CONSISTENCY_UNKNOWN"
//        case CASS_CONSISTENCY_ANY: return "CASS_CONSISTENCY_ANY"
//        case CASS_CONSISTENCY_ONE: return "CASS_CONSISTENCY_ONE"
//        case CASS_CONSISTENCY_TWO: return "CASS_CONSISTENCY_TWO"
//        case CASS_CONSISTENCY_THREE: return "CASS_CONSISTENCY_THREE"
//        case CASS_CONSISTENCY_QUORUM: return "CASS_CONSISTENCY_QUORUM"
//        case CASS_CONSISTENCY_ALL: return "CASS_CONSISTENCY_ALL"
//        case CASS_CONSISTENCY_LOCAL_QUORUM: return "CASS_CONSISTENCY_LOCAL_QUORUM"
//        case CASS_CONSISTENCY_EACH_QUORUM: return "CASS_CONSISTENCY_EACH_QUORUM"
//        case CASS_CONSISTENCY_SERIAL: return "CASS_CONSISTENCY_SERIAL"
//        case CASS_CONSISTENCY_LOCAL_SERIAL: return "CASS_CONSISTENCY_LOCAL_SERIAL"
//        case CASS_CONSISTENCY_LOCAL_ONE: return "CASS_CONSISTENCY_LOCAL_ONE"
//        default: fatalError()
//        }
        if let str = String(validatingUTF8: cass_consistency_string(self)) {
            return str
        } else {
            fatalError() // ne devrait pas se produire
        }
    }
    public static func fromString(_ consistency: String) -> CassConsistency {
        switch consistency {
        case "CASS_CONSISTENCY_UNKNOWN": return CASS_CONSISTENCY_UNKNOWN
        case "CASS_CONSISTENCY_ANY": return CASS_CONSISTENCY_ANY
        case "CASS_CONSISTENCY_ONE": return CASS_CONSISTENCY_ONE
        case "CASS_CONSISTENCY_TWO": return CASS_CONSISTENCY_TWO
        case "CASS_CONSISTENCY_THREE": return CASS_CONSISTENCY_THREE
        case "CASS_CONSISTENCY_QUORUM": return CASS_CONSISTENCY_QUORUM
        case "CASS_CONSISTENCY_ALL": return CASS_CONSISTENCY_ALL
        case "CASS_CONSISTENCY_LOCAL_QUORUM": return CASS_CONSISTENCY_LOCAL_QUORUM
        case "CASS_CONSISTENCY_EACH_QUORUM": return CASS_CONSISTENCY_EACH_QUORUM
        case "CASS_CONSISTENCY_SERIAL": return CASS_CONSISTENCY_SERIAL
        case "CASS_CONSISTENCY_LOCAL_SERIAL": return CASS_CONSISTENCY_LOCAL_SERIAL
        case "CASS_CONSISTENCY_LOCAL_ONE": return CASS_CONSISTENCY_LOCAL_ONE
        default: fatalError()
        }
    }
}

extension CassWriteType: CustomStringConvertible {
    public var description: String {
//        switch self {
//        case CASS_WRITE_TYPE_UNKNOWN: return "CASS_WRITE_TYPE_UNKNOWN"
//        case CASS_WRITE_TYPE_SIMPLE: return "CASS_WRITE_TYPE_SIMPLE"
//        case CASS_WRITE_TYPE_BATCH: return "CASS_WRITE_TYPE_BATCH"
//        case CASS_WRITE_TYPE_UNLOGGED_BATCH: return "CASS_WRITE_TYPE_UNLOGGED_BATCH"
//        case CASS_WRITE_TYPE_COUNTER: return "CASS_WRITE_TYPE_COUNTER"
//        case CASS_WRITE_TYPE_BATCH_LOG: return "CASS_WRITE_TYPE_BATCH_LOG"
//        case CASS_WRITE_TYPE_CAS: return "CASS_WRITE_TYPE_CAS"
//        default: fatalError()
//        }
        if let str = String(validatingUTF8: cass_write_type_string(self)) {
            return str
        } else {
            fatalError() // ne devrait pas se produire
        }
    }
}

extension CassColumnType: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_COLUMN_TYPE_REGULAR: return "CASS_COLUMN_TYPE_REGULAR"
        case CASS_COLUMN_TYPE_PARTITION_KEY: return "CASS_COLUMN_TYPE_PARTITION_KEY"
        case CASS_COLUMN_TYPE_CLUSTERING_KEY: return "CASS_COLUMN_TYPE_CLUSTERING_KEY"
        case CASS_COLUMN_TYPE_STATIC: return "CASS_COLUMN_TYPE_STATIC"
        case CASS_COLUMN_TYPE_COMPACT_VALUE: return "CASS_COLUMN_TYPE_COMPACT_VALUE"
        default: fatalError()
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
        default: fatalError()
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
        default: fatalError()
        }
    }
}

extension CassClusteringOrder: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_CLUSTERING_ORDER_NONE: return "CASS_CLUSTERING_ORDER_NONE"
        case CASS_CLUSTERING_ORDER_ASC: return "CASS_CLUSTERING_ORDER_ASC"
        case CASS_CLUSTERING_ORDER_DESC: return "CASS_CLUSTERING_ORDER_DESC"
        default: fatalError()
        }
    }
}

extension CassCollectionType: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_COLLECTION_TYPE_LIST: return "CASS_COLLECTION_TYPE_LIST"
        case CASS_COLLECTION_TYPE_MAP: return "CASS_COLLECTION_TYPE_MAP"
        case CASS_COLLECTION_TYPE_SET: return "CASS_COLLECTION_TYPE_SET"
        default: fatalError()
        }
    }
}

extension CassIteratorType: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_ITERATOR_TYPE_RESULT: return "CASS_ITERATOR_TYPE_RESULT"
        case CASS_ITERATOR_TYPE_ROW: return "CASS_ITERATOR_TYPE_ROW"
        case CASS_ITERATOR_TYPE_COLLECTION: return "CASS_ITERATOR_TYPE_COLLECTION"
        case CASS_ITERATOR_TYPE_MAP: return "CASS_ITERATOR_TYPE_MAP"
        case CASS_ITERATOR_TYPE_TUPLE: return "CASS_ITERATOR_TYPE_TUPLE"
        case CASS_ITERATOR_TYPE_USER_TYPE_FIELD: return "CASS_ITERATOR_TYPE_USER_TYPE_FIELD"
        case CASS_ITERATOR_TYPE_META_FIELD: return "CASS_ITERATOR_TYPE_META_FIELD"
        case CASS_ITERATOR_TYPE_KEYSPACE_META: return "CASS_ITERATOR_TYPE_KEYSPACE_META"
        case CASS_ITERATOR_TYPE_TABLE_META: return "CASS_ITERATOR_TYPE_TABLE_META"
        case CASS_ITERATOR_TYPE_TYPE_META: return "CASS_ITERATOR_TYPE_TYPE_META"
        case CASS_ITERATOR_TYPE_FUNCTION_META: return "CASS_ITERATOR_TYPE_FUNCTION_META"
        case CASS_ITERATOR_TYPE_AGGREGATE_META: return "CASS_ITERATOR_TYPE_AGGREGATE_META"
        case CASS_ITERATOR_TYPE_COLUMN_META: return "CASS_ITERATOR_TYPE_COLUMN_META"
        case CASS_ITERATOR_TYPE_INDEX_META: return "CASS_ITERATOR_TYPE_INDEX_META"
        case CASS_ITERATOR_TYPE_MATERIALIZED_VIEW_META: return "CASS_ITERATOR_TYPE_MATERIALIZED_VIEW_META"
        default: fatalError()
        }
    }
}

extension CassLogLevel: CustomStringConvertible {
    public var description: String {
//        switch self {
//        case CASS_LOG_DISABLED: return "CASS_LOG_DISABLED"
//        case CASS_LOG_CRITICAL: return "CASS_LOG_CRITICAL"
//        case CASS_LOG_ERROR: return "CASS_LOG_ERROR"
//        case CASS_LOG_WARN: return "CASS_LOG_WARN"
//        case CASS_LOG_INFO: return "CASS_LOG_INFO"
//        case CASS_LOG_DEBUG: return "CASS_LOG_DEBUG"
//        case CASS_LOG_TRACE: return "CASS_LOG_TRACE"
//        default: fatalError()
//        }
        if let str = String(validatingUTF8: cass_log_level_string(self)) {
            return str
        } else {
            fatalError() // ne devrait pas se produire
        }
    }
}

extension CassSslVerifyFlags: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_SSL_VERIFY_NONE: return "CASS_SSL_VERIFY_NONE"
        case CASS_SSL_VERIFY_PEER_CERT: return "CASS_SSL_VERIFY_PEER_CERT"
        case CASS_SSL_VERIFY_PEER_IDENTITY: return "CASS_SSL_VERIFY_PEER_IDENTITY"
        case CASS_SSL_VERIFY_PEER_IDENTITY_DNS: return "CASS_SSL_VERIFY_PEER_IDENTITY_DNS"
        default: fatalError()
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
        default: fatalError()
        }
    }
}

extension CassError: CustomStringConvertible {
    public var description: String {
//        switch self {
//        case CASS_OK: return "CASS_OK"
//        case CASS_ERROR_LIB_BAD_PARAMS: return "CASS_ERROR_LIB_BAD_PARAMS"
//        case CASS_ERROR_LIB_NO_STREAMS: return "CASS_ERROR_LIB_NO_STREAMS"
//        case CASS_ERROR_LIB_UNABLE_TO_INIT: return "CASS_ERROR_LIB_UNABLE_TO_INIT"
//        case CASS_ERROR_LIB_MESSAGE_ENCODE: return "CASS_ERROR_LIB_MESSAGE_ENCODE"
//        case CASS_ERROR_LIB_HOST_RESOLUTION: return "CASS_ERROR_LIB_HOST_RESOLUTION"
//        case CASS_ERROR_LIB_UNEXPECTED_RESPONSE: return "CASS_ERROR_LIB_UNEXPECTED_RESPONSE"
//        case CASS_ERROR_LIB_REQUEST_QUEUE_FULL: return "CASS_ERROR_LIB_REQUEST_QUEUE_FULL"
//        case CASS_ERROR_LIB_NO_AVAILABLE_IO_THREAD: return "CASS_ERROR_LIB_NO_AVAILABLE_IO_THREAD"
//        case CASS_ERROR_LIB_WRITE_ERROR: return "CASS_ERROR_LIB_WRITE_ERROR"
//        case CASS_ERROR_LIB_NO_HOSTS_AVAILABLE: return "CASS_ERROR_LIB_NO_HOSTS_AVAILABLE"
//        case CASS_ERROR_LIB_INDEX_OUT_OF_BOUNDS: return "CASS_ERROR_LIB_INDEX_OUT_OF_BOUNDS"
//        case CASS_ERROR_LIB_INVALID_ITEM_COUNT: return "CASS_ERROR_LIB_INVALID_ITEM_COUNT"
//        case CASS_ERROR_LIB_INVALID_VALUE_TYPE: return "CASS_ERROR_LIB_INVALID_VALUE_TYPE"
//        case CASS_ERROR_LIB_REQUEST_TIMED_OUT: return "CASS_ERROR_LIB_REQUEST_TIMED_OUT"
//        case CASS_ERROR_LIB_UNABLE_TO_SET_KEYSPACE: return "CASS_ERROR_LIB_UNABLE_TO_SET_KEYSPACE"
//        case CASS_ERROR_LIB_CALLBACK_ALREADY_SET: return "CASS_ERROR_LIB_CALLBACK_ALREADY_SET"
//        case CASS_ERROR_LIB_INVALID_STATEMENT_TYPE: return "CASS_ERROR_LIB_INVALID_STATEMENT_TYPE"
//        case CASS_ERROR_LIB_NAME_DOES_NOT_EXIST: return "CASS_ERROR_LIB_NAME_DOES_NOT_EXIST"
//        case CASS_ERROR_LIB_UNABLE_TO_DETERMINE_PROTOCOL: return "CASS_ERROR_LIB_UNABLE_TO_DETERMINE_PROTOCOL"
//        case CASS_ERROR_LIB_NULL_VALUE: return "CASS_ERROR_LIB_NULL_VALUE"
//        case CASS_ERROR_LIB_NOT_IMPLEMENTED: return "CASS_ERROR_LIB_NOT_IMPLEMENTED"
//        case CASS_ERROR_LIB_UNABLE_TO_CONNECT: return "CASS_ERROR_LIB_UNABLE_TO_CONNECT"
//        case CASS_ERROR_LIB_UNABLE_TO_CLOSE: return "CASS_ERROR_LIB_UNABLE_TO_CLOSE"
//        case CASS_ERROR_LIB_NO_PAGING_STATE: return "CASS_ERROR_LIB_NO_PAGING_STATE"
//        case CASS_ERROR_LIB_PARAMETER_UNSET: return "CASS_ERROR_LIB_PARAMETER_UNSET"
//        case CASS_ERROR_LIB_INVALID_ERROR_RESULT_TYPE: return "CASS_ERROR_LIB_INVALID_ERROR_RESULT_TYPE"
//        case CASS_ERROR_LIB_INVALID_FUTURE_TYPE: return "CASS_ERROR_LIB_INVALID_FUTURE_TYPE"
//        case CASS_ERROR_LIB_INTERNAL_ERROR: return "CASS_ERROR_LIB_INTERNAL_ERROR"
//        case CASS_ERROR_LIB_INVALID_CUSTOM_TYPE: return "CASS_ERROR_LIB_INVALID_CUSTOM_TYPE"
//        case CASS_ERROR_LIB_INVALID_DATA: return "CASS_ERROR_LIB_INVALID_DATA"
//        case CASS_ERROR_LIB_NOT_ENOUGH_DATA: return "CASS_ERROR_LIB_NOT_ENOUGH_DATA"
//        case CASS_ERROR_LIB_INVALID_STATE: return "CASS_ERROR_LIB_INVALID_STATE"
//        case CASS_ERROR_LIB_NO_CUSTOM_PAYLOAD: return "CASS_ERROR_LIB_NO_CUSTOM_PAYLOAD"
//
//        case CASS_ERROR_SERVER_SERVER_ERROR: return "CASS_ERROR_SERVER_SERVER_ERROR"
//        case CASS_ERROR_SERVER_PROTOCOL_ERROR: return "CASS_ERROR_SERVER_PROTOCOL_ERROR"
//        case CASS_ERROR_SERVER_BAD_CREDENTIALS: return "CASS_ERROR_SERVER_BAD_CREDENTIALS"
//        case CASS_ERROR_SERVER_UNAVAILABLE: return "CASS_ERROR_SERVER_UNAVAILABLE"
//        case CASS_ERROR_SERVER_OVERLOADED: return "CASS_ERROR_SERVER_OVERLOADED"
//        case CASS_ERROR_SERVER_IS_BOOTSTRAPPING: return "CASS_ERROR_SERVER_IS_BOOTSTRAPPING"
//        case CASS_ERROR_SERVER_TRUNCATE_ERROR: return "CASS_ERROR_SERVER_TRUNCATE_ERROR"
//        case CASS_ERROR_SERVER_WRITE_TIMEOUT: return "CASS_ERROR_SERVER_WRITE_TIMEOUT"
//        case CASS_ERROR_SERVER_READ_TIMEOUT: return "CASS_ERROR_SERVER_READ_TIMEOUT"
//        case CASS_ERROR_SERVER_READ_FAILURE: return "CASS_ERROR_SERVER_READ_FAILURE"
//        case CASS_ERROR_SERVER_FUNCTION_FAILURE: return "CASS_ERROR_SERVER_FUNCTION_FAILURE"
//        case CASS_ERROR_SERVER_WRITE_FAILURE: return "CASS_ERROR_SERVER_WRITE_FAILURE"
//        case CASS_ERROR_SERVER_SYNTAX_ERROR: return "CASS_ERROR_SERVER_SYNTAX_ERROR"
//        case CASS_ERROR_SERVER_UNAUTHORIZED: return "CASS_ERROR_SERVER_UNAUTHORIZED"
//        case CASS_ERROR_SERVER_INVALID_QUERY: return "CASS_ERROR_SERVER_INVALID_QUERY"
//        case CASS_ERROR_SERVER_CONFIG_ERROR: return "CASS_ERROR_SERVER_CONFIG_ERROR"
//        case CASS_ERROR_SERVER_ALREADY_EXISTS: return "CASS_ERROR_SERVER_ALREADY_EXISTS"
//        case CASS_ERROR_SERVER_UNPREPARED: return "CASS_ERROR_SERVER_UNPREPARED"
//
//        case CASS_ERROR_SSL_INVALID_CERT: return "CASS_ERROR_SSL_INVALID_CERT"
//        case CASS_ERROR_SSL_INVALID_PRIVATE_KEY: return "CASS_ERROR_SSL_INVALID_PRIVATE_KEY"
//        case CASS_ERROR_SSL_NO_PEER_CERT: return "CASS_ERROR_SSL_NO_PEER_CERT"
//        case CASS_ERROR_SSL_INVALID_PEER_CERT: return "CASS_ERROR_SSL_INVALID_PEER_CERT"
//        case CASS_ERROR_SSL_IDENTITY_MISMATCH: return "CASS_ERROR_SSL_IDENTITY_MISMATCH"
//        case CASS_ERROR_SSL_PROTOCOL_ERROR: return "CASS_ERROR_SSL_PROTOCOL_ERROR"
//
//        default: fatalError()
//        }
        if let str = String(validatingUTF8: cass_error_desc(self)) {
            return str
        } else {
            fatalError() // ne devrait pas se produire
        }
    }
}

