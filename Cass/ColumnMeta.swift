//
//  ColumnMeta.swift
//  Cass
//
//  Created by Philippe on 26/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

//import Foundation

public struct ColumnMeta {
    let column_meta: OpaquePointer
    init?(_ column_meta_: OpaquePointer?) {
        if let column_meta = column_meta_ {
            self.column_meta = column_meta
        } else {
            return nil
        }
    }
    public var name: String {
        var name: UnsafePointer<Int8>?
        var name_length: Int = 0
        cass_column_meta_name(column_meta, &name, &name_length)
        if let str = utf8_string(text: name, len: name_length) {
            return str
        } else {
            fatalError("Ne devrait pas arriver")
        }
    }
    var type: CassColumnType {
        return cass_column_meta_type(column_meta)
    }
    public var dataType: DataType {
        return DataType(cass_column_meta_data_type(column_meta))!
    }
    public func field(name: String) -> Value? {
        return Value(cass_column_meta_field_by_name(column_meta, name))
    }
    public var fields: FieldColumnIterator {
        return FieldColumnIterator(column_meta)
    }
}
