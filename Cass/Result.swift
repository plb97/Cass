//
//  ResultSet.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

public
class Result {
    let result: OpaquePointer
    init(_ future: OpaquePointer) {
        if let rs = cass_future_get_result(future) {
            result = rs
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    deinit {
        cass_result_free(result)
    }
    public var count: Int {
        let ctr = cass_result_row_count(result)
        return ctr
    }
    public var columnCount: Int {
        let ctr = cass_result_column_count(result)
        return ctr
    }
    public var hasMorePages: Bool {
        return cass_true == cass_result_has_more_pages(result)
    }
    public var first: Row? {
        if let row = cass_result_first_row(result) {
            return Row(row)
        }
        return nil
    }
    public var rows: ResultIterator {
        return ResultIterator(result)
    }
}


