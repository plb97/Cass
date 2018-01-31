//
//  Authenticatore.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public protocol Response {
    var response: Array<UInt8>? { get }
    var error: String? { get }
    var data: UnsafeMutableRawPointer? { get }
}
public extension Response {
    var error: String? { return nil }
    var data: UnsafeMutableRawPointer? { return nil }
}

public struct Authenticator {
    let auth: OpaquePointer
    init(auth: OpaquePointer) {
        self.auth = auth
    }
    public var address: Inet {
        let ptr = UnsafeMutablePointer<CassInet>.allocate(capacity: 1)
        cass_authenticator_address(auth, ptr)
        let addr = Inet(cass: ptr.pointee)
        return addr
    }
    public var hostname: String {
        return String(cass_authenticator_hostname, ptr: auth)!
    }
    public var className: String {
        return String(cass_authenticator_class_name, ptr: auth)!
    }
    var exchangeData: UnsafeMutableRawPointer? {
        get { return cass_authenticator_exchange_data(auth) }
        set (exchange_data) { cass_authenticator_set_exchange_data(auth, exchange_data) }
    }
    public func setResponse(response: Response) {
        if let error = response.error {
            cass_authenticator_set_error(auth, error)
            return
        }
        if let resp = response.response {
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

