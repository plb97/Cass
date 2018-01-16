//
//  ColumnType.swift
//  Cass
//
//  Created by Philippe on 16/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

public enum ColumnType: CustomStringConvertible {
    case regular
    case partitionKey
    case clusteringKey
    case static_
    case compactValue
    init(_ cass: CassColumnType) {
        self = ColumnType.fromCass(cass)
    }
    public var description: String {
        switch self {
        case .regular:
            return "CASS_COLUMN_TYPE_REGULAR"
        case .partitionKey:
            return "CASS_COLUMN_TYPE_PARTITION_KEY"
        case .clusteringKey:
            return "CASS_COLUMN_TYPE_CLUSTERING_KEY"
        case .static_:
            return "CASS_COLUMN_TYPE_STATIC"
        case .compactValue:
            return "CASS_COLUMN_TYPE_COMPACT_VALUE"
        }
    }
    var cass: CassColumnType {
        switch self {
        case .regular:
            return CASS_COLUMN_TYPE_REGULAR
        case .partitionKey:
            return CASS_COLUMN_TYPE_PARTITION_KEY
        case .clusteringKey:
            return CASS_COLUMN_TYPE_CLUSTERING_KEY
        case .static_:
            return CASS_COLUMN_TYPE_STATIC
        case .compactValue:
            return CASS_COLUMN_TYPE_COMPACT_VALUE
        }
    }
    private static func fromCass(_ cass: CassColumnType) -> ColumnType {
        switch cass {
        case CASS_COLUMN_TYPE_REGULAR:
            return .regular
        case CASS_COLUMN_TYPE_PARTITION_KEY:
            return .partitionKey
        case CASS_COLUMN_TYPE_CLUSTERING_KEY:
            return .clusteringKey
        case CASS_COLUMN_TYPE_STATIC:
            return .static_
        case CASS_COLUMN_TYPE_COMPACT_VALUE:
            return .compactValue
        default:
            fatalError(FATAL_ERROR_MESSAGE)
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
        default: fatalError(FATAL_ERROR_MESSAGE)
        }
    }
}
