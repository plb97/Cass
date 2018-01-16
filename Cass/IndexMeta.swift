//
//  IndexMeta.swift
//  Cass
//
//  Created by Philippe on 26/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public class IndexMeta {
    public struct FieldSubscript {
        let indexMeta: IndexMeta
        init(_ indexMeta: IndexMeta) {
            self.indexMeta = indexMeta
        }
        public typealias Element = Value?
        public subscript(name: String) -> Element {
            get {
                return Value(cass_index_meta_field_by_name(indexMeta.index_meta, name))
            }
        }
    }
    let index_meta: OpaquePointer
    lazy public var field = FieldSubscript(self)
    init?(_ index_meta_: OpaquePointer?) {
        if let index_meta = index_meta_ {
            self.index_meta = index_meta
        } else {
            return nil
        }
    }
    public var name: String {
        if let str = String(f: cass_index_meta_name, ptr: index_meta) {
            return str
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    public var indexType: IndexType {
        return IndexType(cass_index_meta_type(index_meta))
    }
    public var target: String {
        if let res = String(f:cass_index_meta_target, ptr: index_meta) {
            return res
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    public var options: Value {
        if let res = Value(cass_index_meta_options(index_meta)) {
            return res
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    public func field(name: String) -> Value? {
        return Value(cass_index_meta_field_by_name(index_meta, name))
    }


}
