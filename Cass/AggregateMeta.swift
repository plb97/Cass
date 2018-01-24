//
//  AggregateMeta.swift
//  Cass
//
//  Created by Philippe on 22/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public class AggregateMeta {
    public struct ArgumentTypeCollection: Collection {
        let aggregateMeta: AggregateMeta
        init(_ aggregateMeta: AggregateMeta) {
            self.aggregateMeta = aggregateMeta
        }
        // minimum requis pour satisfaire le protocole 'Collection'
        public typealias Element = DataType?
        public var startIndex: Int { return 0 }
        public var endIndex: Int   { return cass_aggregate_meta_argument_count(aggregateMeta.aggregate_meta) }
        public func index(after i: Int) -> Int {
            precondition(i < endIndex, "Can't advance beyond endIndex")
            return i + 1
        }
        public subscript(index: Int) -> Element {
            get {
                precondition(0 <= index && index < endIndex, "index out of bounds")
                return DataType(cass_aggregate_meta_argument_type(aggregateMeta.aggregate_meta, index))
            }
        }
    }
    public struct FieldSubscript {
        let aggregateMeta: AggregateMeta
        init(_ aggregateMeta: AggregateMeta) {
            self.aggregateMeta = aggregateMeta
        }
        public typealias Element = Value?
        public subscript(name: String) -> Element {
            get {
                return Value(cass_aggregate_meta_field_by_name(aggregateMeta.aggregate_meta, name))
            }
        }
    }
    let aggregate_meta: OpaquePointer
    lazy public var argumentType = ArgumentTypeCollection(self)
    lazy public var field = FieldSubscript(self)
    init?(_ aggregate_meta_: OpaquePointer?) {
        if let aggregate_meta = aggregate_meta_ {
            self.aggregate_meta = aggregate_meta
        } else {
            return nil
        }
    }
    public var name: String {
        if let res = String(f: cass_aggregate_meta_name, ptr: aggregate_meta) {
            return res
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    public var fullName: String {
        if let res = String(f: cass_aggregate_meta_full_name, ptr: aggregate_meta) {
            return res
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    public var returnType: DataType {
        return DataType(cass_aggregate_meta_state_type(aggregate_meta))
    }
    public var stateType: DataType {
        return DataType(cass_aggregate_meta_state_type(aggregate_meta))
    }
    public var stateFunc: FunctionMeta {
        if let res = FunctionMeta(cass_aggregate_meta_state_func(aggregate_meta)) {
            return res
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    public var initCond: Value {
        if let res = Value(cass_aggregate_meta_init_cond(aggregate_meta)) {
            return res
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    public var fields: FieldAggregateIterator {
        return FieldAggregateIterator(aggregate_meta)
    }
    public var argumentCount: Int {
        return cass_aggregate_meta_argument_count(aggregate_meta)
    }
    public func argumentType(_ index: Int) -> DataType? {
        return DataType(cass_aggregate_meta_argument_type(aggregate_meta, index))
    }
    public func fieldByName(_ name: String) -> Value? {
        return Value(cass_aggregate_meta_state_func(aggregate_meta))
    }
}
