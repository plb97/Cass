//
//  Authenticatore.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

//import Foundation
/*
public
struct Response {
    public var buffer: [Int8]
    public init(_ size: Int) {
        buffer = Array(repeating: Int8(0), count: size)
    }
    public init(buffer: [Int8]) {
        self.buffer = Array(buffer)
    }
    public func size() -> Int {
        return buffer.count
    }
}
*/
public
struct Authenticator {
    let auth: OpaquePointer?
    init(auth: OpaquePointer?) {
        self.auth = auth
    }
    var address: Inet {
        let addr = UnsafeMutablePointer<CassInet>.allocate(capacity: 1)
        defer {
            addr.deallocate(capacity: 1)
        }
        cass_authenticator_address(auth, addr)
        return Inet(addr.pointee)
    }
    var hostname: String {
        var length: Int = 0
        let data: UnsafePointer<Int8>? = cass_authenticator_hostname(auth, &length)
        return utf8_string(text: data, len: length)!
    }
    var className: String {
        var length: Int = 0
        let data: UnsafePointer<Int8>? = cass_authenticator_class_name(auth, &length)
        return utf8_string(text: data, len: length)!
    }
    var exchangeData: UnsafeMutableRawPointer? {
        get { return cass_authenticator_exchange_data(auth) }
        set (exchange_data) { cass_authenticator_set_exchange_data(auth, exchange_data) }
    }
    func getResponse(size: Int) -> Array<Int8> {
        let data = cass_authenticator_response(auth,size)
        return Array(UnsafeBufferPointer(start: data, count: size))
     }
    func setResponse(data: Array<Int8>) -> () {
        cass_authenticator_set_response(auth,UnsafeMutablePointer(mutating: data),data.count)
    }
    func setError(_ error: String) -> () {
        cass_authenticator_set_error(auth, error)
    }
}

/*
 private func ok(auth_: Authenticator? = nil,data_: UnsafeMutableRawPointer? = nil) -> () {}
 private func ok_token(auth_: Authenticator? = nil,data_: UnsafeMutableRawPointer? = nil,token_: String? = nil) -> () {}
 public
 struct Authenticator {
 public let initial_callback: Authenticator_f
 public let challenge_callback: Authenticator_token_f
 public let success_callback: Authenticator_token_f
 public let cleanup_callback: Authenticator_f
 public let data_: UnsafeMutableRawPointer?
 init(initial_callback: @escaping Authenticator_f = ok,
 challenge_callback: @escaping Authenticator_token_f = ok_token,
 success_callback: @escaping Authenticator_token_f = ok_token,
 cleanup_callback: @escaping Authenticator_f = ok,
 _ data_: UnsafeMutableRawPointer? = nil) {
 self.initial_callback = initial_callback
 self.challenge_callback = challenge_callback
 self.success_callback = success_callback
 self.cleanup_callback = cleanup_callback
 self.data_ = data_
 }
 }
 */
