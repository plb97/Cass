//
//  TableMeta.swift
//  Cass
//
//  Created by Philippe on 22/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public class TableMeta {
    public struct ColumnMetaCollection: Collection {
        let tableMeta: TableMeta
        init(_ tableMeta: TableMeta) {
            self.tableMeta = tableMeta
        }
        // minimum requis pour satisfaire le protocole 'Collection'
        public typealias Element = ColumnMeta?
        public var startIndex: Int { return 0 }
        public var endIndex: Int   { return cass_table_meta_column_count(tableMeta.table_meta) }
        public func index(after i: Int) -> Int {
            precondition(i < endIndex, "Can't advance beyond endIndex")
            return i + 1
        }
        public subscript(index: Int) -> Element {
            get {
                precondition(0 <= index && index < endIndex, "index out of bounds")
                return ColumnMeta(cass_table_meta_column(tableMeta.table_meta, index))
            }
        }
        public subscript(name: String) -> Element {
            get {
                return ColumnMeta(cass_table_meta_column_by_name(tableMeta.table_meta, name))
            }
        }
    }
    public struct IndexMetaCollection: Collection {
        let tableMeta: TableMeta
        init(_ tableMeta: TableMeta) {
            self.tableMeta = tableMeta
        }
        // minimum requis pour satisfaire le protocole 'Collection'
        public typealias Element = IndexMeta?
        public var startIndex: Int { return 0 }
        public var endIndex: Int   { return cass_table_meta_index_count(tableMeta.table_meta) }
        public func index(after i: Int) -> Int {
            precondition(i < endIndex, "Can't advance beyond endIndex")
            return i + 1
        }
        public subscript(index: Int) -> Element {
            get {
                precondition(0 <= index && index < endIndex, "index out of bounds")
                return IndexMeta(cass_table_meta_index(tableMeta.table_meta, index))
            }
        }
        public subscript(name: String) -> Element {
            get {
                return IndexMeta(cass_table_meta_index_by_name(tableMeta.table_meta, name))
            }
        }
    }
    public struct MaterializedViewMetaCollection: Collection {
        let tableMeta: TableMeta
        init(_ tableMeta: TableMeta) {
            self.tableMeta = tableMeta
        }
        // minimum requis pour satisfaire le protocole 'Collection'
        public typealias Element = MaterializedViewMeta?
        public var startIndex: Int { return 0 }
        public var endIndex: Int   { return cass_table_meta_materialized_view_count(tableMeta.table_meta) }
        public func index(after i: Int) -> Int {
            precondition(i < endIndex, "Can't advance beyond endIndex")
            return i + 1
        }
        public subscript(index: Int) -> Element {
            get {
                //precondition(0 <= index && index < endIndex, "index out of bounds")
                return MaterializedViewMeta(cass_table_meta_materialized_view(tableMeta.table_meta, index))
            }
        }
        public subscript(name: String) -> Element {
            get {
                return MaterializedViewMeta(cass_table_meta_index_by_name(tableMeta.table_meta, name))
            }
        }
    }
    public struct PartitionKeyCollection: Collection {
        let tableMeta: TableMeta
        init(_ tableMeta: TableMeta) {
            self.tableMeta = tableMeta
        }
        public typealias Element = ColumnMeta?
        // minimum requis pour satisfaire le protocole 'Collection'
        public var startIndex: Int { return 0 }
        public var endIndex: Int   { return cass_table_meta_partition_key_count(tableMeta.table_meta) }
        public func index(after i: Int) -> Int {
            precondition(i < endIndex, "Can't advance beyond endIndex")
            return i + 1
        }
        public subscript(index: Int) -> Element {
            get {
                //precondition(0 <= index && index < endIndex, "index out of bounds")
                return ColumnMeta(cass_table_meta_partition_key(tableMeta.table_meta, index))
            }
        }
    }
    public struct ClusteringKeyCollection: Collection {
        let tableMeta: TableMeta
        init(_ tableMeta: TableMeta) {
            self.tableMeta = tableMeta
        }
        public typealias Element = ColumnMeta?
        // minimum requis pour satisfaire le protocole 'Collection'
        public var startIndex: Int { return 0 }
        public var endIndex: Int   { return cass_table_meta_clustering_key_count(tableMeta.table_meta) }
        public func index(after i: Int) -> Int {
            precondition(i < endIndex, "Can't advance beyond endIndex")
            return i + 1
        }
        public subscript(index: Int) -> Element {
            get {
                //precondition(0 <= index && index < endIndex, "index out of bounds")
                return ColumnMeta(cass_table_meta_clustering_key(tableMeta.table_meta, index))
            }
        }
    }
    public struct ClusteringKeyOrderSubscript {
        let tableMeta: TableMeta
        init(_ tableMeta: TableMeta) {
            self.tableMeta = tableMeta
        }
        public typealias Element = ClusteringOrder
        public subscript(index: Int) -> Element {
            get {
                return ClusteringOrder(cass_table_meta_clustering_key_order(tableMeta.table_meta, index))
            }
        }
    }
    public struct FieldSubscript {
        let tableMeta: TableMeta
        init(_ tableMeta: TableMeta) {
            self.tableMeta = tableMeta
        }
        public typealias Element = Value?
        public subscript(name: String) -> Element {
            get {
                return Value(cass_table_meta_field_by_name(tableMeta.table_meta, name))
            }
        }
    }

    let table_meta: OpaquePointer
    lazy public var columnMeta = ColumnMetaCollection(self)
    lazy public var indexMeta = IndexMetaCollection(self)
    lazy public var materializedViewMeta = MaterializedViewMetaCollection(self)
    lazy public var partitionKey = PartitionKeyCollection(self)
    lazy public var clusteringKey = ClusteringKeyCollection(self)
    lazy public var field = FieldSubscript(self)
    init?(_ table_meta_: OpaquePointer?) {
        if let table_meta = table_meta_ {
            self.table_meta = table_meta
        }
        else {
            return nil
        }
    }
    public var name: String {
        if let str = String(f: cass_table_meta_name, ptr: table_meta) {
            return str
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    public var columns: ColumnIterator {
        return ColumnIterator(table_meta)
    }
    public var indexes: IndexIterator {
        return IndexIterator(table_meta)
    }
    public var materializedViews: MaterializedViewIterator {
        return MaterializedViewIterator(table_meta)
    }
    public var fields: FieldTableIterator {
        return FieldTableIterator(table_meta)
    }
    public var columnCount: Int {
        return cass_table_meta_column_count(table_meta)
    }
    public func column(index: Int) -> ColumnMeta? {
        return ColumnMeta(cass_table_meta_column(table_meta, index))
    }
    public func column(name: String) -> ColumnMeta? {
        return ColumnMeta(cass_table_meta_column_by_name(table_meta, name))
    }
    public var indexCount: Int {
        return cass_table_meta_index_count(table_meta)
    }
    public func index(index: Int) -> IndexMeta? {
        return IndexMeta(cass_table_meta_index(table_meta, index))
    }
    public func index(name: String) -> IndexMeta? {
        return IndexMeta(cass_table_meta_index_by_name(table_meta, name))
    }
    public var materializedViewCount: Int {
        return cass_table_meta_materialized_view_count(table_meta)
    }
    public func materializedView(index: Int) -> MaterializedViewMeta? {
        return MaterializedViewMeta(cass_table_meta_materialized_view(table_meta, index))
    }
    public func materializedView(name: String) -> MaterializedViewMeta? {
        return MaterializedViewMeta(cass_table_meta_index_by_name(table_meta, name))
    }
    public var partitionKeyCount: Int {
        return cass_table_meta_partition_key_count(table_meta)
    }
    public func partitionKey(index: Int) -> ColumnMeta? {
        return ColumnMeta(cass_table_meta_partition_key(table_meta, index))
    }
    public var clusteringKeyCount: Int {
        return cass_table_meta_clustering_key_count(table_meta)
    }
    public func clusteringKey(index: Int) -> ColumnMeta? {
        return ColumnMeta(cass_table_meta_clustering_key(table_meta, index))
    }
    func clusteringOrder(index: Int) -> CassClusteringOrder {
        return cass_table_meta_clustering_key_order(table_meta, index)
    }
    public func field(name: String) -> Value? {
        return Value(cass_table_meta_field_by_name(table_meta, name))
    }
}
