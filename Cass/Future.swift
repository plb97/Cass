//
//  Future.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

private func future_error_message(_ future: OpaquePointer) -> String {
    if let str = String(f: cass_future_error_message, ptr: future) {
        return str
    } else {
        return ""
    }
}

public
class Future {
    let future: OpaquePointer
    fileprivate var error_code_: Error?
    fileprivate var error_message_: String?
    init(_ future: OpaquePointer) {
        self.future = future
    }
    deinit {
        cass_future_free(future)
    }
    public var ready: Bool {
        return cass_true == cass_future_ready(future)
    }
    public func wait(micros: UInt64) -> Bool { // microsecondes
        return cass_false == cass_future_wait_timed(future, micros)
    }
    public func wait(millis: UInt64) -> Bool { // millisecondes
        return wait(micros: millis * 1_000)
    }
    public func wait(sec: UInt64) -> Bool { // secondes
        return wait(micros: sec * 1_000_000)
    }

    //public
    var errorResult: ErrorResult {
       return ErrorResult(cass_future_get_error_result(future))
    }
    public var errorCode: Error {
        if nil == error_code_ {
            let rc = cass_future_error_code(future)
            error_code_ = Error(rc)
        }
        return error_code_!
    }
    public var errorMessage: String {
        if nil == error_message_ {
            error_message_ = errorCode.ok ? "" : future_error_message(future)
        }
        return error_message_!
    }
    @discardableResult
    public func check(checker: ((_ err: Error) -> Bool) = default_checker) -> Bool {
        return errorCode.check(checker:checker)
    }
    public var prepared: Prepared {
        if let prepared = cass_future_get_prepared(future) {
            return Prepared(prepared)
        }
        fatalError("Ne devrait pas arriver")
    }
    @discardableResult
    public func wait() -> Future {
        cass_future_wait(future)
        return self
    }
    public var result: Result {
        return Result(future)
    }
    /*
     public var customPayloadItemCount: Int {
     return cass_future_custom_payload_item_count(future)
     }
     public func payloadCustom(index: Int) -> CustomPayload? {
     var name: UnsafePointer<Int8>?
     var name_length: Int = 0
     var value: UnsafePointer<UInt8>?
     var value_size: Int = 0
     error_code = Error(cass_future_custom_payload_item(future, index, &name, &name_length, &value, &value_size))
     if error_code.ok {
     return CustomPayload(name: utf8_string(text: name, len: name_length)!, value: value, value_size: value_size)
     } else {
     return nil
     }
     }
     */
}

class StatementFuture: Future {
    let statement: Statement // garde une reference sur le 'statement' durant toute la vie du 'future'
    init(statement: Statement, future: OpaquePointer) {
        self.statement = statement
        super.init(future)
    }
    deinit {
    }
}
