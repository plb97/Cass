//
//  ErrorResult.swift
//  Cass
//
//  Created by Philippe on 28/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public
class ErrorResult: Status {
    let error_result: OpaquePointer
    init(_ error_result: OpaquePointer) {
        self.error_result = error_result
        super.init()
    }
    deinit {
        cass_error_result_free(error_result)
    }
    var code: CassError {
        return cass_error_result_code(error_result)
    }
    var consistency: CassConsistency {
        return cass_error_result_consistency(error_result)
    }
    var writeType: CassWriteType {
        return cass_error_result_write_type(error_result)
    }
    public var responsesReceived: Int32 {
        return cass_error_result_responses_received(error_result)
    }
    public var responsesRequired: Int32 {
        return cass_error_result_responses_required(error_result)
    }
    public var numFailuress: Int32 {
        return cass_error_result_num_failures(error_result)
    }
    public var dataPresent: Bool {
        return cass_true == cass_error_result_data_present(error_result)
    }
    public var keyspace: String? {
        var name: UnsafePointer<Int8>?
        var name_length: Int = 0
        msg_ = message(cass_error_result_keyspace(error_result, &name, &name_length))
        if nil == msg_ {
            return utf8_string(text: name, len: name_length)
        } else {
            return nil
        }
    }
    public var table: String? {
        var name: UnsafePointer<Int8>?
        var name_length: Int = 0
        msg_ = message(cass_error_result_table(error_result, &name, &name_length))
        if nil == msg_ {
            return utf8_string(text: name, len: name_length)
        } else {
            return nil
        }
    }
    public var function: String? {
        var name: UnsafePointer<Int8>?
        var name_length: Int = 0
        msg_ = message(cass_error_result_function(error_result, &name, &name_length))
        if nil == msg_ {
            return utf8_string(text: name, len: name_length)
        } else {
            return nil
        }
    }
    public var argTypes: Int {
        return cass_error_num_arg_types(error_result)
    }
    public func argType(index: Int) -> String? {
        var name: UnsafePointer<Int8>?
        var name_length: Int = 0
        msg_ = message(cass_error_result_arg_type(error_result, index, &name, &name_length))
        if nil == msg_ {
            return utf8_string(text: name, len: name_length)
        } else {
            return nil
        }
    }
}
