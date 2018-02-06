//
//  Future.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

private func future_error_message(_ future: OpaquePointer) -> String {
    if let str = String(function: cass_future_error_message, ptr: future) {
        return str
    } else {
        return ""
    }
}

public
class Future {
    let future: OpaquePointer
    fileprivate var error_code: Error
    fileprivate var checker: Checker
    init(_ future: OpaquePointer) {
        error_code = Error(cass_future_error_code(future))
        self.future = future
        self.checker = fatalChecker
    }
    deinit {
        cass_future_free(future)
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

    public var errorResult: ErrorResult {
       return ErrorResult(cass_future_get_error_result(future))
    }
    public var errorMessage: String {
        if .ok == error_code {
            return ""
        } else {
            return String(future_error_message(future))
        }
    }
    public var prepared: Prepared {
        if let prepared = cass_future_get_prepared(future) {
            return Prepared(prepared)
        }
        fatalError(FATAL_ERROR_MESSAGE)
    }
    @discardableResult
    public func wait() -> Future {
        cass_future_wait(future)
        return self
    }
    public var result: Result {
        return Result(self)
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
