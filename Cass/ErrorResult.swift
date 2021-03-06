//
//  ErrorResult.swift
//  Cass
//
//  Created by Philippe on 28/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public class ErrorResult {
    let error_result: OpaquePointer
    init(_ error_result: OpaquePointer) {
        self.error_result = error_result
    }
    deinit {
        cass_error_result_free(error_result)
    }
    public var code: Error {
        return Error(cass_error_result_code(error_result))
    }
    public var consistency: Consistency {
        return Consistency(cass_error_result_consistency(error_result))
    }
    public var writeType: WriteType {
        return WriteType(cass_error_result_write_type(error_result))
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
        return String(function: cass_error_result_keyspace, ptr: error_result)
    }
    public var table: String? {
        return String(function: cass_error_result_table, ptr: error_result)
    }
    public var function: String? {
        return String(function: cass_error_result_function, ptr: error_result)
    }
    public var numArgTypes: Int {
        return cass_error_num_arg_types(error_result)
    }
    public func argType(index: Int) -> String? {
        return String(function: cass_error_result_arg_type, ptr: error_result, index: index)
    }
}
