//
//  Authenticatore.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

public
struct Authenticator {
    let auth: OpaquePointer
    init(auth: OpaquePointer) {
        self.auth = auth
    }
    public var address: Inet {
        let ptr = UnsafeMutablePointer<CassInet>.allocate(capacity: 1)
        cass_authenticator_address(auth, ptr)
        let addr = Inet(ptr.pointee)
        return addr
    }
    public var hostname: String {
        var length: Int = 0
        let data: UnsafePointer<Int8>? = cass_authenticator_hostname(auth, &length)
        return utf8_string(text: data, len: length)!
    }
    public var className: String {
        var length: Int = 0
        let data: UnsafePointer<Int8>? = cass_authenticator_class_name(auth, &length)
        return utf8_string(text: data, len: length)!
    }
    var exchangeData: UnsafeMutableRawPointer? {
        get { return cass_authenticator_exchange_data(auth) }
        set (exchange_data) { cass_authenticator_set_exchange_data(auth, exchange_data) }
    }
    public func setResponse(response resp_: Array<UInt8>?) -> () {
        if let resp = resp_ {
            let ptr = UnsafeMutableRawPointer(UnsafeMutablePointer<UInt8>(mutating: resp))
                .bindMemory(to: Int8.self, capacity: resp.count)
            defer {
                ptr.deinitialize(count: resp.count)
            }
            cass_authenticator_set_response(auth, ptr, resp.count)
        }
    }
    func setError(_ error: String) -> () {
        cass_authenticator_set_error(auth, error)
    }
}

