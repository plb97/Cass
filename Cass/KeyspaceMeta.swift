//
//  KeyspaceMeta.swift
//  Cass
//
//  Created by Philippe on 22/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//


public class KeyspaceMeta {
    public struct TableMetaSubscript {
        let keyspaceMeta: KeyspaceMeta
        init(_ keyspaceMeta: KeyspaceMeta) {
            self.keyspaceMeta = keyspaceMeta
        }
        public typealias Element = TableMeta?
        public subscript(table: String) -> Element {
            get {
                return TableMeta(cass_keyspace_meta_table_by_name(keyspaceMeta.keyspace_meta, table))
            }
        }
    }

    public struct MaterializedViewMetaSubscript {
        let keyspaceMeta: KeyspaceMeta
        init(_ keyspaceMeta: KeyspaceMeta) {
            self.keyspaceMeta = keyspaceMeta
        }
        public typealias Element = MaterializedViewMeta?
        public subscript(view: String) -> Element {
            get {
                return MaterializedViewMeta(cass_keyspace_meta_materialized_view_by_name(keyspaceMeta.keyspace_meta, view))
            }
        }
    }

    public struct UserTypeSubscript {
        let keyspaceMeta: KeyspaceMeta
        init(_ keyspaceMeta: KeyspaceMeta) {
            self.keyspaceMeta = keyspaceMeta
        }
        public typealias Element = DataType?
        public subscript(type: String) -> Element {
            get {
                return DataType(cass_keyspace_meta_user_type_by_name(keyspaceMeta.keyspace_meta, type))
            }
        }
    }

    public struct FunctionMetaSubscript {
        let keyspaceMeta: KeyspaceMeta
        init(_ keyspaceMeta: KeyspaceMeta) {
            self.keyspaceMeta = keyspaceMeta
        }
        public typealias Element = FunctionMeta?
        public subscript(name: String, arguments: String) -> Element {
            get {
                return FunctionMeta(cass_keyspace_meta_function_by_name(keyspaceMeta.keyspace_meta, name, arguments))
            }
        }
    }

    public struct AggregateMetaSubscript {
        let keyspaceMeta: KeyspaceMeta
        init(_ keyspaceMeta: KeyspaceMeta) {
            self.keyspaceMeta = keyspaceMeta
        }
        public typealias Element = AggregateMeta?
        public subscript(name: String, arguments: String) -> Element {
            get {
                return AggregateMeta(cass_keyspace_meta_aggregate_by_name(keyspaceMeta.keyspace_meta, name, arguments))
            }
        }
    }

    public struct FieldSubscript {
        let keyspaceMeta: KeyspaceMeta
        init(_ keyspaceMeta: KeyspaceMeta) {
            self.keyspaceMeta = keyspaceMeta
        }
        public typealias Element = Value?
        public subscript(name: String) -> Element {
            get {
                return Value(cass_keyspace_meta_field_by_name(keyspaceMeta.keyspace_meta, name))
            }
        }
    }
    let keyspace_meta: OpaquePointer
    lazy public var tableMeta = TableMetaSubscript(self)
    lazy public var materializedViewMeta = MaterializedViewMetaSubscript(self)
    lazy public var userType = UserTypeSubscript(self)
    lazy public var functionMeta = FunctionMetaSubscript(self)
    lazy public var aggregateMeta = AggregateMetaSubscript(self)
    lazy public var field = FieldSubscript(self)
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
            fatalError(FATAL_ERROR_MESSAGE)
        }
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

}

