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
class FutureBase: Error {
    static func setCallback(_ future: OpaquePointer,_ listener: Listener) -> () {
        let ptr = UnsafeMutablePointer<Listener>.allocate(capacity: MemoryLayout<Listener>.stride)
        ptr.initialize(to: listener)
        cass_future_set_callback(future, callback_f, ptr)
    }
    var future: OpaquePointer
    init(_ future: OpaquePointer) {
        print("init FutureBase",future)
        self.future = future
        super.init(error_message(future))
    }
    deinit {
        print("deinit FutureBase", future)
        cass_future_free(future)
    }
    public var ready: Bool {
        return cass_true == cass_future_ready(future)
    }
    func wait(timed: UInt64? = nil) -> () {
        if let duration = timed {
            cass_future_wait_timed(future, duration)
        } else {
            cass_future_wait(future)
        }
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

public
class Future: FutureBase {
    init(_ future: OpaquePointer, timed: UInt64? = nil) {
        print("init Future")
        super.init(future)
        if let duration = timed {
            cass_future_wait_timed(future, duration)
        } else {
            cass_future_wait(future)
        }
    }
    deinit {
        print("deinit Future")
    }
}

