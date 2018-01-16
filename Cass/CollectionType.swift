//
//  CollectionType.swift
//  Cass
//
//  Created by Philippe on 16/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

public enum CollectionType: CustomStringConvertible {
    case list
    case map
    case set
    init(_ cass: CassCollectionType) {
        self = CollectionType.fromCass(cass)
    }
    public var description: String {
        switch self {
        case .list:
            return "CASS_COLLECTION_TYPE_LIST"
        case .map:
            return "CASS_COLLECTION_TYPE_MAP"
        case .set:
            return "CASS_COLLECTION_TYPE_SET"
        }
    }
    var cass: CassCollectionType {
        switch self {
        case .list:
            return CASS_COLLECTION_TYPE_LIST
        case .map:
            return CASS_COLLECTION_TYPE_MAP
        case .set:
            return CASS_COLLECTION_TYPE_SET
        }
    }
    private static func fromCass(_ cass: CassCollectionType) -> CollectionType {
        switch cass {
        case CASS_COLLECTION_TYPE_LIST:
            return .list
        case CASS_COLLECTION_TYPE_MAP:
            return .map
        case CASS_COLLECTION_TYPE_SET:
            return .set
        default:
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
}

extension CassCollectionType: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_COLLECTION_TYPE_LIST: return "CASS_COLLECTION_TYPE_LIST"
        case CASS_COLLECTION_TYPE_MAP: return "CASS_COLLECTION_TYPE_MAP"
        case CASS_COLLECTION_TYPE_SET: return "CASS_COLLECTION_TYPE_SET"
        default: fatalError(FATAL_ERROR_MESSAGE)
        }
    }
}

