//
//  ClusteringOrder.swift
//  Cass
//
//  Created by Philippe on 15/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

public enum ClusteringOrder: CustomStringConvertible {
    case none
    case asc
    case desc
    init(_ cass: CassClusteringOrder) {
        self = ClusteringOrder.fromCass(cass)
    }
    public var description: String {
        switch self {
        case .none:
            return "CASS_CLUSTERING_ORDER_NONE"
        case .asc:
            return "CASS_CLUSTERING_ORDER_ASC"
        case .desc:
            return "CASS_CLUSTERING_ORDER_DESC"
        }
    }
    var cass: CassClusteringOrder {
        switch self {
        case .none:
            return CASS_CLUSTERING_ORDER_NONE
        case .asc:
            return CASS_CLUSTERING_ORDER_ASC
        case .desc:
            return CASS_CLUSTERING_ORDER_DESC
        }
    }
    private static func fromCass(_ cass: CassClusteringOrder) -> ClusteringOrder {
        switch cass {
        case CASS_CLUSTERING_ORDER_ASC:
            return .asc
        case CASS_CLUSTERING_ORDER_DESC:
            return .desc
        default:
            return .none
        }
    }
}

extension CassClusteringOrder: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_CLUSTERING_ORDER_NONE: return "CASS_CLUSTERING_ORDER_NONE"
        case CASS_CLUSTERING_ORDER_ASC: return "CASS_CLUSTERING_ORDER_ASC"
        case CASS_CLUSTERING_ORDER_DESC: return "CASS_CLUSTERING_ORDER_DESC"
        default: fatalError(FATAL_ERROR_MESSAGE)
        }
    }
}

