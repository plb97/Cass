//
//  Iterator.swift
//  Cass
//
//  Created by Philippe on 22/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

//import Foundation

public
class Iterator: Error {
    let iterator_: OpaquePointer?
    fileprivate init(rowsFromResult meta_: OpaquePointer?) {
        if let meta = meta_ {
            iterator_ = cass_iterator_from_result(meta)
        } else {
            iterator_ = nil
        }
        super.init()
    }
    fileprivate init(valuesFromCollection meta_: OpaquePointer?) {
        if let meta = meta_ {
            iterator_ = cass_iterator_from_collection(meta)
        } else {
            iterator_ = nil
        }
        super.init()
    }
    fileprivate init(itemsFromMap meta_: OpaquePointer?) {
        if let meta = meta_ {
            iterator_ = cass_iterator_from_map(meta)
        } else {
            iterator_ = nil
        }
        super.init()
    }
    fileprivate init(fieldsFromKeyspaceMeta meta_: OpaquePointer?) {
        if let meta = meta_ {
            iterator_ = cass_iterator_fields_from_keyspace_meta(meta )
        } else {
            iterator_ = nil
        }
        super.init()
    }
    fileprivate init(fieldsFromAggregateMeta meta_: OpaquePointer?) {
        if let meta = meta_ {
            iterator_ = cass_iterator_fields_from_aggregate_meta(meta)
        } else {
            iterator_ = nil
        }
        super.init()
    }
    fileprivate init(fieldsFromTableMeta meta_: OpaquePointer?) {
        if let meta = meta_ {
            iterator_ = cass_iterator_fields_from_table_meta(meta)
        } else {
            iterator_ = nil
        }
        super.init()
    }
    fileprivate init(fieldsFromFunctionMeta meta_: OpaquePointer?) {
        if let meta = meta_ {
            iterator_ = cass_iterator_fields_from_function_meta(meta)
        } else {
            iterator_ = nil
        }
        super.init()
    }
    fileprivate init(fieldsFromColumnMeta meta_: OpaquePointer?) {
        if let meta = meta_ {
            iterator_ = cass_iterator_fields_from_column_meta(meta)
        } else {
            iterator_ = nil
        }
        super.init()
    }
    fileprivate init(tablesFromKeyspaceMeta meta_: OpaquePointer?) {
        if let meta = meta_ {
            iterator_ = cass_iterator_tables_from_keyspace_meta(meta)
        } else {
            iterator_ = nil
        }
    }
    fileprivate init(functionsFromKeyspaceMeta meta_: OpaquePointer?) {
        if let meta = meta_ {
            iterator_ = cass_iterator_functions_from_keyspace_meta(meta)
        } else {
            iterator_ = nil
        }
    }
    fileprivate init(aggregatesFromKeyspaceMeta meta_: OpaquePointer?) {
        if let meta = meta_ {
            iterator_ = cass_iterator_aggregates_from_keyspace_meta(meta)
        } else {
            iterator_ = nil
        }
    }
    fileprivate init(columnsFromTableMeta meta_: OpaquePointer?) {
        if let meta = meta_ {
            iterator_ = cass_iterator_columns_from_table_meta(meta)
        } else {
            iterator_ = nil
        }
    }
    fileprivate init(indexesFromTableMeta meta_: OpaquePointer?) {
        if let meta = meta_ {
            iterator_ = cass_iterator_indexes_from_table_meta(meta)
        } else {
            iterator_ = nil
        }
    }
    fileprivate init(materializedViewsFromTableMeta meta_: OpaquePointer?) {
        if let meta = meta_ {
            iterator_ = cass_iterator_materialized_views_from_table_meta(meta)
        } else {
            iterator_ = nil
        }
    }
    deinit {
        if let iterator = iterator_ {
            cass_iterator_free(iterator)
        }
    }
    func hasNext() -> Bool {
        if let iterator = iterator_ {
            return cass_true == cass_iterator_next(iterator)
        }
        return false
    }
    var row: Row? {
        if hasNext() {
            return Row(cass_iterator_get_row(iterator_!))
        }
        return nil
    }
    var column: Value? {
        if hasNext() {
            return Value(cass_iterator_get_column(iterator_!))
        }
        return nil
    }
    var value: Value? {
        if hasNext() {
            return Value(cass_iterator_get_value(iterator_!))
        }
        return nil
    }
    var keyValue: (key: AnyHashable, value: Any?)? {
        if hasNext() {
            if let key = Value(cass_iterator_get_map_key(iterator_!))?.anyHashable {
                let val = Value(cass_iterator_get_map_value(iterator_!))?.any
                return (key: key, value: val)
            }
        }
        return nil
    }
    var userTypeField: (name: String, value: Value?)? {
        if hasNext() {
            var name: UnsafePointer<Int8>?
            var name_length: Int = 0
            msg_ = message(cass_iterator_get_user_type_field_name(iterator_!, &name, &name_length))
            if let str = utf8_string(text: name, len: name_length) {
                return (name: str, value: Value(cass_iterator_get_user_type_field_value(iterator_!)))
            }
        }
        return nil
    }
    var keyspaceMeta: KeyspaceMeta? {
        if hasNext() {
            return KeyspaceMeta(cass_iterator_get_keyspace_meta(iterator_!))
        }
        return nil
    }
    var tableMeta: TableMeta? {
        if hasNext() {
            return TableMeta(cass_iterator_get_table_meta(iterator_!))
        }
        return nil
    }
    var materializedViewMeta: MaterializedViewMeta? {
        if hasNext() {
            return MaterializedViewMeta(cass_iterator_get_materialized_view_meta(iterator_!))
        }
        return nil
    }
    var userType: DataType? {
        if hasNext() {
            return DataType(cass_iterator_get_user_type(iterator_!))
        }
        return nil
    }
    var functionMeta: FunctionMeta? {
        if hasNext() {
            return FunctionMeta(cass_iterator_get_function_meta(iterator_!))
        }
        return nil
    }
    var aggregateMeta: AggregateMeta? {
        if hasNext() {
            return AggregateMeta(cass_iterator_get_aggregate_meta(iterator_!))
        }
        return nil
    }
    var columnMeta: ColumnMeta? {
        if hasNext() {
            return ColumnMeta(cass_iterator_get_column_meta(iterator_!))
        }
        return nil
    }
    var indexMeta: IndexMeta? {
        if hasNext() {
            return IndexMeta(cass_iterator_get_index_meta(iterator_!))
        }
        return nil
    }
    var metaField: (name: String, value: Any?)? {
        if hasNext() {
            var name: UnsafePointer<Int8>?
            var name_length: Int = 0
            msg_ = message(cass_iterator_get_meta_field_name(iterator_!, &name, &name_length))
            if let str = utf8_string(text: name, len: name_length) {
                return (name: str, value: Value(cass_iterator_get_meta_field_value(iterator_!))?.any)
            }
        }
        return nil
    }
    var type: CassIteratorType {
        return cass_iterator_type(iterator_!)
    }

//    public func next() -> Any? {
//        switch type {
//        case CASS_ITERATOR_TYPE_RESULT: return row
//        case CASS_ITERATOR_TYPE_ROW: return column
//        case CASS_ITERATOR_TYPE_COLLECTION: return value
//        case CASS_ITERATOR_TYPE_MAP: return keyValue
//        //case CASS_ITERATOR_TYPE_TUPLE: return tuple
//        case CASS_ITERATOR_TYPE_USER_TYPE_FIELD: return userTypeField
//        case CASS_ITERATOR_TYPE_META_FIELD: return metaField
//        case CASS_ITERATOR_TYPE_KEYSPACE_META: return keyspaceMeta
//        case CASS_ITERATOR_TYPE_TABLE_META: return tableMeta
//       // case CASS_ITERATOR_TYPE_TYPE_META: return typeMeta
//        case CASS_ITERATOR_TYPE_FUNCTION_META: return functionMeta
//        case CASS_ITERATOR_TYPE_AGGREGATE_META: return aggregateMeta
//        case CASS_ITERATOR_TYPE_COLUMN_META: return columnMeta
//        case CASS_ITERATOR_TYPE_INDEX_META: return indexMeta
//        case CASS_ITERATOR_TYPE_MATERIALIZED_VIEW_META: return materializedViewMeta
//        default:
//            fatalError()
//            //return nil
//        }
//    }
}

public
class RowIterator: Iterator, Sequence, IteratorProtocol {
    public typealias Element = Row
    init(_ result_: OpaquePointer?) {
        super.init(rowsFromResult: result_)
    }
    public func next() -> Row? {
        return row
    }

}

public
class CollectionIterator: Iterator, Sequence, IteratorProtocol {
    public typealias Element = Any
    init(_ collection: OpaquePointer) {
        super.init(valuesFromCollection: collection)
    }
    public func next() -> Any? {
        return value?.any
    }
}

public
class MapIterator: Iterator, Sequence, IteratorProtocol {
    public typealias Element = (key: AnyHashable, value: Any?)
    init(_ map: OpaquePointer) {
        super.init(itemsFromMap: map)
    }
    public func next() -> (key: AnyHashable, value: Any?)? {
        return keyValue
    }
}

public
class TableIterator: Iterator, Sequence, IteratorProtocol {
    public typealias Element = TableMeta
    init(_ keyspace_meta: OpaquePointer) {
        super.init(tablesFromKeyspaceMeta: keyspace_meta)
    }
    public func next() -> TableMeta? {
        return tableMeta
    }
}
public
class FunctionIterator: Iterator, Sequence, IteratorProtocol {
    public typealias Element = FunctionMeta
    init(_ keyspace_meta: OpaquePointer) {
        super.init(functionsFromKeyspaceMeta: keyspace_meta)
    }
    public func next() -> FunctionMeta? {
        return functionMeta
    }
}
public
class AggregateIterator: Iterator, Sequence, IteratorProtocol {
    public typealias Element = AggregateMeta
    init(_ keyspace_meta: OpaquePointer) {
        super.init(aggregatesFromKeyspaceMeta: keyspace_meta)
    }
    public func next() -> AggregateMeta? {
        return aggregateMeta
    }
}

public
class ColumnIterator: Iterator, Sequence, IteratorProtocol {
    public typealias Element = ColumnMeta
    init(_ table_meta: OpaquePointer) {
        super.init(columnsFromTableMeta: table_meta)
    }
    public func next() -> ColumnMeta? {
        return columnMeta
    }
}

public
class IndexIterator: Iterator, Sequence, IteratorProtocol {
    public typealias Element = IndexMeta
    init(_ table_meta: OpaquePointer) {
        super.init(indexesFromTableMeta: table_meta)
    }
    public func next() -> IndexMeta? {
        return indexMeta
    }
}

public
class FieldKeyspaceIterator: Iterator, Sequence, IteratorProtocol {
    public typealias Element = (name: String, value: Any?)
    init(_ keyspace_meta: OpaquePointer) {
        super.init(fieldsFromKeyspaceMeta: keyspace_meta)
    }
    public func next() -> (name: String, value: Any?)? {
        return metaField
    }
}

public
class FieldAggregateIterator: Iterator, Sequence, IteratorProtocol {
    public typealias Element = (name: String, value: Any?)
    init(_ aggregate_meta: OpaquePointer) {
        super.init(fieldsFromAggregateMeta: aggregate_meta)
    }
    public func next() -> (name: String, value: Any?)? {
        return metaField
    }
}

public
class FieldTableIterator: Iterator, Sequence, IteratorProtocol {
    public typealias Element = (name: String, value: Any?)
    init(_ table_meta: OpaquePointer) {
        super.init(fieldsFromTableMeta: table_meta)
    }
    public func next() -> (name: String, value: Any?)? {
        return metaField
    }
}

public
class FieldFunctionIterator: Iterator, Sequence, IteratorProtocol {
    public typealias Element = (name: String, value: Any?)
    init(_ function_meta: OpaquePointer) {
        super.init(fieldsFromFunctionMeta: function_meta)
    }
    public func next() -> (name: String, value: Any?)? {
        return metaField
    }
}

public
class MaterializedViewIterator: Iterator, Sequence, IteratorProtocol {
    public typealias Element = MaterializedViewMeta
    init(_ table_meta: OpaquePointer) {
        super.init(materializedViewsFromTableMeta: table_meta)
    }
    public func next() -> MaterializedViewMeta? {
        return materializedViewMeta
    }
}

public
class FieldColumnIterator: Iterator, Sequence, IteratorProtocol {
    public typealias Element = (name: String, value: Any?)
    init(_ column_meta: OpaquePointer) {
        super.init(fieldsFromColumnMeta: column_meta)
    }
    public func next() -> (name: String, value: Any?)? {
        return metaField
    }
}

