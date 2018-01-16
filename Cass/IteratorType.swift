//
//  IteratorType.swift
//  Cass
//
//  Created by Philippe on 16/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

public enum IteratorType: CustomStringConvertible {
    case result
    case row
    case collection
    case map
    case tuple
    case userTypeField
    case metaField
    case keyspaceMeta
    case tableMeta
    case typeMeta
    case functionMeta
    case aggregateMeta
    case columnMeta
    case indexMeta
    case materializedView
    init(_ cass: CassIteratorType) {
        self = IteratorType.fromCass(cass)
    }
    public var description: String {
        switch self {
        case .result:
            return "CASS_ITERATOR_TYPE_RESULT"
        case .row:
            return "CASS_ITERATOR_TYPE_ROW"
        case .collection:
            return "CASS_ITERATOR_TYPE_COLLECTION"
        case .map:
            return "CASS_ITERATOR_TYPE_MAP"
        case .tuple:
            return "CASS_ITERATOR_TYPE_TUPLE"
        case .userTypeField:
            return "CASS_ITERATOR_TYPE_USER_TYPE_FIELD"
        case .metaField:
            return "CASS_ITERATOR_TYPE_META_FIELD"
        case .keyspaceMeta:
            return "CASS_ITERATOR_TYPE_KEYSPACE_META"
        case .tableMeta:
            return "CASS_ITERATOR_TYPE_TABLE_META"
        case .typeMeta:
            return "CASS_ITERATOR_TYPE_TYPE_META"
        case .functionMeta:
            return "CASS_ITERATOR_TYPE_FUNCTION_META"
        case .aggregateMeta:
            return "CASS_ITERATOR_TYPE_AGGREGATE_META"
        case .columnMeta:
            return "CASS_ITERATOR_TYPE_COLUMN_META"
        case .indexMeta:
            return "CASS_ITERATOR_TYPE_INDEX_META"
        case .materializedView:
            return "CASS_ITERATOR_TYPE_MATERIALIZED_VIEW_META"
        }
    }
    var cass: CassIteratorType {
        switch self {
        case .result:
            return CASS_ITERATOR_TYPE_RESULT
        case .row:
            return CASS_ITERATOR_TYPE_ROW
        case .collection:
            return CASS_ITERATOR_TYPE_COLLECTION
        case .map:
            return CASS_ITERATOR_TYPE_MAP
        case .tuple:
            return CASS_ITERATOR_TYPE_TUPLE
        case .userTypeField:
            return CASS_ITERATOR_TYPE_USER_TYPE_FIELD
        case .metaField:
            return CASS_ITERATOR_TYPE_META_FIELD
        case .keyspaceMeta:
            return CASS_ITERATOR_TYPE_KEYSPACE_META
        case .tableMeta:
            return CASS_ITERATOR_TYPE_TABLE_META
        case .typeMeta:
            return CASS_ITERATOR_TYPE_TYPE_META
        case .functionMeta:
            return CASS_ITERATOR_TYPE_FUNCTION_META
        case .aggregateMeta:
            return CASS_ITERATOR_TYPE_AGGREGATE_META
        case .columnMeta:
            return CASS_ITERATOR_TYPE_COLUMN_META
        case .indexMeta:
            return CASS_ITERATOR_TYPE_INDEX_META
        case .materializedView:
            return CASS_ITERATOR_TYPE_MATERIALIZED_VIEW_META
        }
    }
    private static func fromCass(_ cass: CassIteratorType) -> IteratorType {
        switch cass {
        case CASS_ITERATOR_TYPE_RESULT:
            return .result
        case CASS_ITERATOR_TYPE_ROW:
            return .row
        case CASS_ITERATOR_TYPE_COLLECTION:
            return .collection
        case CASS_ITERATOR_TYPE_MAP:
            return .map
        case CASS_ITERATOR_TYPE_TUPLE:
            return .tuple
        case CASS_ITERATOR_TYPE_USER_TYPE_FIELD:
            return .userTypeField
        case CASS_ITERATOR_TYPE_META_FIELD:
            return .metaField
        case CASS_ITERATOR_TYPE_KEYSPACE_META:
            return .keyspaceMeta
        case CASS_ITERATOR_TYPE_TABLE_META:
            return .tableMeta
        case CASS_ITERATOR_TYPE_TYPE_META:
            return .typeMeta
        case CASS_ITERATOR_TYPE_FUNCTION_META:
            return .functionMeta
        case CASS_ITERATOR_TYPE_AGGREGATE_META:
            return .aggregateMeta
        case CASS_ITERATOR_TYPE_COLUMN_META:
            return .columnMeta
        case CASS_ITERATOR_TYPE_INDEX_META:
            return .indexMeta
        case CASS_ITERATOR_TYPE_MATERIALIZED_VIEW_META:
            return .materializedView
        default:
            fatalError(FATAL_ERROR_MESSAGE)
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
        default: fatalError(FATAL_ERROR_MESSAGE)
        }
    }
}


