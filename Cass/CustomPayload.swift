//
//  CustomPayload.swift
//  Cass
//
//  Created by Philippe on 24/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public
class CustomPayload {
    let payload: OpaquePointer!
    init() {
        payload = cass_custom_payload_new()
    }
    init(name: String, value: UnsafePointer<UInt8>?, value_size: Int) {
        payload = cass_custom_payload_new()
        cass_custom_payload_set(payload, name, value, value_size)
    }
    deinit {
        cass_custom_payload_free(payload)
    }
    public func set(name: String, value: Array<UInt8>) {
        cass_custom_payload_set(payload, name, value, value.count)
    }
    public func remove(name: String) {
        cass_custom_payload_remove(payload, name)
    }
}
