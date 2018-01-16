//
//  Consistency.swift
//  Cass
//
//  Created by Philippe on 16/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

public enum Consistency: CustomStringConvertible {
    case unknown
    case any
    case one
    case two
    case three
    case quorum
    case all
    case localQuorum
    case eachQuorum
    case localOne
    init(_ cass: CassConsistency) {
        self = Consistency.fromCass(cass)
    }
    public var description: String {
        switch self {
        case .unknown:
            return "CASS_CONSISTENCY_UNKNOWN"
        case .any:
            return "CASS_CONSISTENCY_ANY"
        case .one:
            return "CASS_CONSISTENCY_ONE"
        case .two:
            return "CASS_CONSISTENCY_TWO"
        case .three:
            return "CASS_CONSISTENCY_THREE"
        case .quorum:
            return "CASS_CONSISTENCY_QUORUM"
        case .all:
            return "CASS_CONSISTENCY_ALL"
        case .localQuorum:
            return "CASS_CONSISTENCY_LOCAL_QUORUM"
        case .eachQuorum:
            return "CASS_CONSISTENCY_EACH_QUORUM"
        case .localOne:
            return "CASS_CONSISTENCY_LOCAL_ONE"
        }
    }
    var cass: CassConsistency {
        switch self {
        case .unknown:
            return CASS_CONSISTENCY_UNKNOWN
        case .any:
            return CASS_CONSISTENCY_ANY
        case .one:
            return CASS_CONSISTENCY_ONE
        case .two:
            return CASS_CONSISTENCY_TWO
        case .three:
            return CASS_CONSISTENCY_THREE
        case .quorum:
            return CASS_CONSISTENCY_QUORUM
        case .all:
            return CASS_CONSISTENCY_ALL
        case .localQuorum:
            return CASS_CONSISTENCY_LOCAL_QUORUM
        case .eachQuorum:
            return CASS_CONSISTENCY_EACH_QUORUM
        case .localOne:
            return CASS_CONSISTENCY_LOCAL_ONE
        }
    }
    private static func fromCass(_ cass: CassConsistency) -> Consistency {
        switch cass {
        case CASS_CONSISTENCY_ANY:
            return .any
        case CASS_CONSISTENCY_ONE:
            return .one
        case CASS_CONSISTENCY_TWO:
            return .two
        case CASS_CONSISTENCY_THREE:
            return .three
        case CASS_CONSISTENCY_QUORUM:
            return .quorum
        case CASS_CONSISTENCY_ALL:
            return .all
        case CASS_CONSISTENCY_LOCAL_QUORUM:
            return .localQuorum
        case CASS_CONSISTENCY_EACH_QUORUM:
            return .eachQuorum
        case CASS_CONSISTENCY_LOCAL_ONE:
            return .localOne
        default:
            return .unknown
        }
    }
}

public enum SerialConsistency: CustomStringConvertible {
    case unknown
    case serial
    case localSerial
    init(_ cass: CassConsistency) {
        self = SerialConsistency.fromCass(cass)
    }
    public var description: String {
        switch self {
        case .serial:
            return "CASS_CONSISTENCY_SERIAL"
        case .localSerial:
            return "CASS_CONSISTENCY_LOCAL_SERIAL"
        default:
            return "CASS_CONSISTENCY_UNKNOWN"
        }
    }
    var cass: CassConsistency {
        switch self {
        case .serial:
            return CASS_CONSISTENCY_SERIAL
        case .localSerial:
            return CASS_CONSISTENCY_LOCAL_SERIAL
        default:
            return CASS_CONSISTENCY_UNKNOWN
        }
    }
    private static func fromCass(_ cass: CassConsistency) -> SerialConsistency {
        switch cass {
        case CASS_CONSISTENCY_SERIAL:
            return .serial
        case CASS_CONSISTENCY_LOCAL_SERIAL:
            return .localSerial
        default:
            return .unknown
        }
    }
}

extension CassConsistency: CustomStringConvertible {
    public var description: String {
        if let str = String(validatingUTF8: cass_consistency_string(self)) {
            return str
        } else {
            fatalError(FATAL_ERROR_MESSAGE) // ne devrait pas se produire
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
        default: fatalError(FATAL_ERROR_MESSAGE)
        }
    }
}

