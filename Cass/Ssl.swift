//
//  Ssl.swift
//  Cass
//
//  Created by Philippe on 05/02/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

public class Ssl {
    let ssl: OpaquePointer
    var error_code: Error
    var checker: Checker
    public init() {
        if let ssl = cass_ssl_new() {
            self.ssl = ssl
            error_code = Error()
            self.checker = fatalChecker
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    deinit {
        cass_ssl_free(ssl)
    }
    @discardableResult
    public func setChecker(_ checker: @escaping Checker = fatalChecker) -> Self {
        self.checker = checker
        return self
    }
    @discardableResult
    public func check() -> Bool {
        return error_code.check(checker: checker)
    }
    @discardableResult
    public func setVerifyFlags(_ verif: SslVerifyFlags...) -> Ssl {
        if 0 == verif.count {
            cass_ssl_set_verify_flags(ssl, Int32(CASS_SSL_VERIFY_NONE.rawValue))
        } else {
            var flags: Int = 0
            for f in verif {
                flags |= Int(f.cass.rawValue)
            }
            cass_ssl_set_verify_flags(ssl, Int32(flags))
        }
        return self
    }
    @discardableResult
    public func addTrustedCert(_ cert: String) -> Ssl {
        if .ok == error_code {
            error_code = Error(cass_ssl_add_trusted_cert(ssl, cert))
            if .ok != error_code {
                cass_ssl_set_verify_flags(ssl, Int32(CASS_SSL_VERIFY_NONE.rawValue))
            }
        }
        return self
    }
    @discardableResult
    public func setCert(_ cert: String) -> Ssl {
        if .ok == error_code {
            error_code = Error(cass_ssl_set_cert(ssl, cert))
            if .ok != error_code {
                cass_ssl_set_verify_flags(ssl, Int32(CASS_SSL_VERIFY_NONE.rawValue))
            }
        }
        return self
    }
    @discardableResult
    public func setPrivateKey(key: String, password: String? = nil) -> Ssl {
        if .ok == error_code {
            error_code = Error(cass_ssl_set_private_key(ssl, key, password))
            if .ok != error_code {
                cass_ssl_set_verify_flags(ssl, Int32(CASS_SSL_VERIFY_NONE.rawValue))
            }
        }
        return self
    }
    public var cass: OpaquePointer {
        return ssl
    }
}
