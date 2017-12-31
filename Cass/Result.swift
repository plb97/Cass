//
//  ResultSet.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

//import Foundation

public
class Result: Error {
    let result_: OpaquePointer?
    init(_ future: OpaquePointer) {
        let rc = cass_future_error_code(future)
        if CASS_OK == rc {
            result_ = cass_future_get_result(future)
            super.init()
        } else {
            result_ = nil
            super.init(error_message(future))
        }
    }
    deinit {
        if let result = result_ {
            cass_result_free(result)
        }
    }
    public func count() -> Int {
        if let result = result_ {
            let ctr = cass_result_row_count(result)
            return ctr
        }
        return 0
    }
    public func column_count() -> Int {
        if let result = result_ {
            let ctr = cass_result_column_count(result)
            return ctr
        }
        return 0
    }
    public func first() -> Row? {
        if let result = result_ {
            if let row = cass_result_first_row(result) {
                return Row(row)
            }
        }
        return nil
    }
    public func rows() -> RowIterator {
        return RowIterator(result_)
    }
}


