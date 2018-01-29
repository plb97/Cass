//
//  MaterializedViewMeta.swift
//  Cass
//
//  Created by Philippe on 22/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public class MaterializedViewMeta {
    public struct ColumnMetaCollection: Collection {
        let viewMeta: MaterializedViewMeta
        init(_ viewMeta: MaterializedViewMeta) {
            self.viewMeta = viewMeta
        }
        public typealias Element = ColumnMeta?
        public subscript(column: String) -> Element {
            get {
                return ColumnMeta(cass_materialized_view_meta_column_by_name(viewMeta.view_meta, column))
            }
        }
        // minimum requis pour satisfaire le protocole 'Collection'
        public var startIndex: Int { return 0 }
        public var endIndex: Int   { return cass_materialized_view_meta_column_count(viewMeta.view_meta) }
        public func index(after i: Int) -> Int {
            precondition(i < endIndex, "Can't advance beyond endIndex")
            return i + 1
        }
        public subscript(index: Int) -> Element {
            get {
                //precondition(0 <= index && index < endIndex, "index out of bounds")
                return ColumnMeta(cass_materialized_view_meta_column(viewMeta.view_meta, index))
            }
        }
    }
    public struct PartitionKeyCollection: Collection {
        let viewMeta: MaterializedViewMeta
        init(_ viewMeta: MaterializedViewMeta) {
            self.viewMeta = viewMeta
        }
        public typealias Element = ColumnMeta?
        // minimum requis pour satisfaire le protocole 'Collection'
        public var startIndex: Int { return 0 }
        public var endIndex: Int   { return cass_materialized_view_meta_partition_key_count(viewMeta.view_meta) }
        public func index(after i: Int) -> Int {
            precondition(i < endIndex, "Can't advance beyond endIndex")
            return i + 1
        }
        public subscript(index: Int) -> Element {
            get {
                //precondition(0 <= index && index < endIndex, "index out of bounds")
                return ColumnMeta(cass_materialized_view_meta_partition_key(viewMeta.view_meta, index))
            }
        }
    }
    public struct ClusteringKeyCollection: Collection {
        let viewMeta: MaterializedViewMeta
        init(_ viewMeta: MaterializedViewMeta) {
            self.viewMeta = viewMeta
        }
        public typealias Element = ColumnMeta?
        // minimum requis pour satisfaire le protocole 'Collection'
        public var startIndex: Int { return 0 }
        public var endIndex: Int   { return cass_materialized_view_meta_clustering_key_count(viewMeta.view_meta) }
        public func index(after i: Int) -> Int {
            precondition(i < endIndex, "Can't advance beyond endIndex")
            return i + 1
        }
        public subscript(index: Int) -> Element {
            get {
                //precondition(0 <= index && index < endIndex, "index out of bounds")
                return ColumnMeta(cass_materialized_view_meta_clustering_key(viewMeta.view_meta, index))
            }
        }
    }
    public struct ClusteringKeyOrderSubscript {
        let viewMeta: MaterializedViewMeta
        init(_ viewMeta: MaterializedViewMeta) {
            self.viewMeta = viewMeta
        }
        public typealias Element = ClusteringOrder
        public subscript(index: Int) -> Element {
            get {
                return ClusteringOrder(cass_materialized_view_meta_clustering_key_order(viewMeta.view_meta, index))
            }
        }
    }
    public struct FieldSubscript {
        let viewMeta: MaterializedViewMeta
        init(_ viewMeta: MaterializedViewMeta) {
            self.viewMeta = viewMeta
        }
        public typealias Element = Value?
        public subscript(name: String) -> Element {
            get {
                return Value(cass_materialized_view_meta_field_by_name(viewMeta.view_meta, name))
            }
        }
    }

    let view_meta: OpaquePointer
    lazy public var columnMeta = ColumnMetaCollection(self)
    lazy public var partitionKey = PartitionKeyCollection(self)
    lazy public var clusteringKey = ClusteringKeyCollection(self)
    lazy public var clusteringKeyOrder = ClusteringKeyOrderSubscript(self)
    lazy public var field = FieldSubscript(self)
    init?(_ view_meta_: OpaquePointer?) {
        if let view_meta = view_meta_ {
            self.view_meta = view_meta
        }
        else {
            return nil
        }
    }
    public var name: String {
        if let res = String(function: cass_materialized_view_meta_name, ptr: view_meta) {
            return res
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    public var baseTable: TableMeta {
        if let res = TableMeta(cass_materialized_view_meta_base_table(view_meta)) {
            return res
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    public func metaColumn(name column: String) -> ColumnMeta? {
        return ColumnMeta(cass_materialized_view_meta_column_by_name(view_meta, column))
    }
    public func metaColumn(index: Int) -> ColumnMeta? {
        //precondition(0 <= index && index < endIndex, "index out of bounds")
        return ColumnMeta(cass_materialized_view_meta_column(view_meta, index))
    }
    public func partitionKey(index: Int) -> ColumnMeta? {
        //precondition(0 <= index && index < endIndex, "index out of bounds")
        return ColumnMeta(cass_materialized_view_meta_partition_key(view_meta, index))
    }
    public func clusteringKey(index: Int) -> ColumnMeta? {
        //precondition(0 <= index && index < endIndex, "index out of bounds")
        return ColumnMeta(cass_materialized_view_meta_clustering_key(view_meta, index))
    }
    public func clusteringOrder(index: Int) -> ClusteringOrder {
        return ClusteringOrder(cass_materialized_view_meta_clustering_key_order(view_meta, index))
    }
    public func field(name: String) -> Value? {
        return Value(cass_materialized_view_meta_field_by_name(view_meta, name))
    }
}
