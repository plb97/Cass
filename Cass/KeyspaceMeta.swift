//
//  KeyspaceMeta.swift
//  Cass
//
//  Created by Philippe on 22/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public
struct KeyspaceMeta {
    let keyspace_meta: OpaquePointer
    init?(_ keyspace_meta_: OpaquePointer?) {
        if let keyspace_meta = keyspace_meta_ {
            self.keyspace_meta = keyspace_meta
        } else {
            return nil
        }
    }
    public var name: String {
        if let str = String(f: cass_keyspace_meta_name, ptr: keyspace_meta) {
            return str
        } else {
            fatalError("Ne devrait pas arriver")
        }
    }
    public func tableMeta(table: String) -> TableMeta? {
        return TableMeta(cass_keyspace_meta_table_by_name(keyspace_meta, table))
    }
    public func materializedViewMeta(view: String) -> MaterializedViewMeta? {
        return MaterializedViewMeta(cass_keyspace_meta_materialized_view_by_name(keyspace_meta, view))
    }
    public func userType(type: String) -> DataType? {
        return DataType(cass_keyspace_meta_user_type_by_name(keyspace_meta, type))
    }
    public func functionMeta(name: String, arguments: String) -> FunctionMeta? {
        return FunctionMeta(cass_keyspace_meta_function_by_name(keyspace_meta, name, arguments))
    }
    public func aggregateMeta(name: String, arguments: String) -> AggregateMeta? {
        return AggregateMeta(cass_keyspace_meta_aggregate_by_name(keyspace_meta, name, arguments))
    }
    public func field(name: String) -> Value? {
        return Value(cass_keyspace_meta_field_by_name(keyspace_meta, name))
    }
    public var fields: FieldKeyspaceIterator {
        return FieldKeyspaceIterator(keyspace_meta)
    }
    public var tables: TableIterator {
        return TableIterator(keyspace_meta)
    }
    public var functions: FunctionIterator {
        return FunctionIterator(keyspace_meta)
    }
    public var aggregates: AggregateIterator {
        return AggregateIterator(keyspace_meta)
    }
}

