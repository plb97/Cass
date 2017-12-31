//
//  Row.swift
//  Cass
//
//  Created by Philippe on 22/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

//import Foundation

public
struct Row {
    let row: OpaquePointer
    init?(_ row_: OpaquePointer?) {
        if let row = row_ {
            self.row = row
        } else {
            return nil
        }
    }
    public func any(_ i: Int) -> Any? {
        let col = Value(cass_row_get_column(row, i))
        let val = col?.any
        return val
    }
    public func any(name: String) -> Any? {
        let col = Value(cass_row_get_column_by_name(row, name))
        let val = col?.any
        return val
    }
}

