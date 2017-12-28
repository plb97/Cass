//
//  TableMeta.swift
//  Cass
//
//  Created by Philippe on 22/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

//import Foundation

public
struct TableMeta {
    let table_meta: OpaquePointer
    init?(_ table_meta_: OpaquePointer?) {
        if let table_meta = table_meta_ {
            self.table_meta = table_meta
        }
        else {
            return nil
        }
    }
    public var name: String {
        var name: UnsafePointer<Int8>?
        var name_length: Int = 0
        cass_table_meta_name(table_meta, &name, &name_length)
        if let str = utf8_string(text: name, len: name_length) {
            return str
        } else {
            fatalError("Ne devrait pas arriver")
        }
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
    public var columns: ColumnIterator {
        return ColumnIterator(table_meta)
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
    public var indexes: IndexIterator {
        return IndexIterator(table_meta)
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
    public var materializedViews: MaterializedViewIterator {
        return MaterializedViewIterator(table_meta)
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
    public var fields: FieldTableIterator {
        return FieldTableIterator(table_meta)
    }
}
