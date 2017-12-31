//
//  Future.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

//import Foundation

func error_message(_ future_: OpaquePointer?) -> String? {
    if let future = future_ {
        var text: UnsafePointer<Int8>?
        var len: Int = 0
        cass_future_error_message(future, &text, &len)
        if 0 < len {
            return utf8_string(text: text, len: len)
        } else {
            return nil
        }
    }
    return nil
}

public
class Future: Error {
    static func setCallback(_ future: OpaquePointer,_ listener: Listener) -> () {
        let ptr = UnsafeMutablePointer<Listener>.allocate(capacity: MemoryLayout<Listener>.stride)
        ptr.initialize(to: listener)
        cass_future_set_callback(future, callback_f, ptr)
    }
    var future: OpaquePointer
    init(_ future: OpaquePointer) {
        self.future = future
        super.init(error_message(future))
    }
    deinit {
        cass_future_free(future)
    }
    public var ready: Bool {
        return cass_true == cass_future_ready(future)
    }
    public func wait() -> Future {
        cass_future_wait(future)
        return self
    }
    public func wait(micros: UInt64) -> Future { // microsecondes
        let timedout = cass_false == cass_future_wait_timed(future, micros)
        if timedout {
            msg_ = "TIMED OUT"
        }
        return self
    }
    public func wait(millis: UInt64) -> Future { // millisecondes
        return wait(micros: millis * 1_000)
    }
    public func wait(sec: UInt64) -> Future { // secondes
        return wait(micros: sec * 1_000_000)
    }
    public var result: Result {
        return Result(future)
    }
    public var errorResult: ErrorResult {
        return ErrorResult(cass_future_get_error_result(future))
    }
    var errorCode: CassError {
        return cass_future_error_code(future)
    }
    public var errorMessage: String? {
        return error_message(future)
    }
    public var customPayloadItemCount: Int {
        return cass_future_custom_payload_item_count(future)
    }
    public func payloadCustom(index: Int) -> CustomPayload? {
        var name: UnsafePointer<Int8>?
        var name_length: Int = 0
        var value: UnsafePointer<UInt8>?
        var value_size: Int = 0
        msg_ = message(cass_future_custom_payload_item(future, index, &name, &name_length, &value, &value_size))
        if nil == msg_ {
            return CustomPayload(name: utf8_string(text: name, len: name_length)!, value: value, value_size: value_size)
        } else {
            return nil
        }
    }
}

