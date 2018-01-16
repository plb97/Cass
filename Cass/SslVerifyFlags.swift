//
//  SslVerifyFlags.swift
//  Cass
//
//  Created by Philippe on 16/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

public enum SslVerifyFlags: CustomStringConvertible {
    case none
    case peerCert
    case peerIdentity
    case peerIdentityDns
    init(_ cass: CassSslVerifyFlags) {
        self = SslVerifyFlags.fromCass(cass)
    }
    public var description: String {
        switch self {
        case .none:
            return "CASS_SSL_VERIFY_NONE"
        case .peerCert:
            return "CASS_SSL_VERIFY_PEER_CERT"
        case .peerIdentity:
            return "CASS_SSL_VERIFY_PEER_IDENTITY"
        case .peerIdentityDns:
            return "CASS_SSL_VERIFY_PEER_IDENTITY_DNS"
        }
    }
    var cass: CassSslVerifyFlags {
        switch self {
        case .none:
            return CASS_SSL_VERIFY_NONE
        case .peerCert:
            return CASS_SSL_VERIFY_PEER_CERT
        case .peerIdentity:
            return CASS_SSL_VERIFY_PEER_IDENTITY
        case .peerIdentityDns:
            return CASS_SSL_VERIFY_PEER_IDENTITY_DNS
        }
    }
    private static func fromCass(_ cass: CassSslVerifyFlags) -> SslVerifyFlags {
        switch cass {
        case CASS_SSL_VERIFY_NONE:
            return .none
        case CASS_SSL_VERIFY_PEER_CERT:
            return .peerCert
        case CASS_SSL_VERIFY_PEER_IDENTITY:
            return .peerIdentity
        case CASS_SSL_VERIFY_PEER_IDENTITY_DNS:
            return .peerIdentityDns
        default:
            fatalError(FATAL_ERROR_MESSAGE)
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
        default: fatalError(FATAL_ERROR_MESSAGE)
        }
    }
}

