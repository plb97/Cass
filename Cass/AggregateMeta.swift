//
//  AggregateMeta.swift
//  Cass
//
//  Created by Philippe on 22/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

//import Foundation

public
struct AggregateMeta {
    let aggregate_meta: OpaquePointer
    init?(_ aggregate_meta_: OpaquePointer?) {
        if let aggregate_meta = aggregate_meta_ {
            self.aggregate_meta = aggregate_meta
        } else {
            return nil
        }
    }
    public var name: String {
        var name: UnsafePointer<Int8>?
        var name_length: Int = 0
        cass_aggregate_meta_name(aggregate_meta, &name, &name_length)
        return utf8_string(text: name, len: name_length)!
    }
    public var fullName: String {
        var full_name: UnsafePointer<Int8>?
        var full_name_length: Int = 0
        cass_aggregate_meta_full_name(aggregate_meta, &full_name, &full_name_length)
        return utf8_string(text: full_name, len: full_name_length)!
    }
    public var argumentCount: Int {
        return cass_aggregate_meta_argument_count(aggregate_meta)
    }
    public func argumentType(_ index: Int) -> DataType? {
        return DataType(cass_aggregate_meta_argument_type(aggregate_meta, index))
    }
    public var returnType: DataType {
        return DataType(cass_aggregate_meta_state_type(aggregate_meta))!
    }
    public var stateType: DataType {
        return DataType(cass_aggregate_meta_state_type(aggregate_meta))!
    }
    public var stateFunc: FunctionMeta {
        return FunctionMeta(cass_aggregate_meta_state_func(aggregate_meta))!
    }
    public var initCond: Value {
        return Value(cass_aggregate_meta_state_func(aggregate_meta))!
    }
    public func fieldByName(_ name: String) -> Value? {
        return Value(cass_aggregate_meta_state_func(aggregate_meta))
    }
    public var fields: FieldAggregateIterator {
        return FieldAggregateIterator(aggregate_meta)
    }
}
