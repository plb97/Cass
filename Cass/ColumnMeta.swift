//
//  ColumnMeta.swift
//  Cass
//
//  Created by Philippe on 26/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public class ColumnMeta {
    public struct FieldSubscript {
        let columnMeta: ColumnMeta
        init(_ columnMeta: ColumnMeta) {
            self.columnMeta = columnMeta
        }
        public typealias Element = Value?
        public subscript(name: String) -> Element {
            get {
                return Value(cass_column_meta_field_by_name(columnMeta.column_meta, name))
            }
        }
    }
    let column_meta: OpaquePointer
    lazy public var field = FieldSubscript(self)
    init?(_ column_meta_: OpaquePointer?) {
        if let column_meta = column_meta_ {
            self.column_meta = column_meta
        } else {
            return nil
        }
    }
    public var name: String {
        if let str = String(function: cass_column_meta_name, ptr: column_meta) {
            return str
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    var type: CassColumnType {
        return cass_column_meta_type(column_meta)
    }
    public var dataType: DataType {
        return DataType(cass_column_meta_data_type(column_meta))
    }
    public var fields: FieldColumnIterator {
        return FieldColumnIterator(column_meta)
    }
    public func field(name: String) -> Value? {
        return Value(cass_column_meta_field_by_name(column_meta, name))
    }

}
