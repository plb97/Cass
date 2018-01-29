//
//  Iterator.swift
//  Cass
//
//  Created by Philippe on 22/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public
class Iterator {
    var error_code: Error
    let iterator_: OpaquePointer?
    fileprivate init(rowsFromResult meta_: OpaquePointer?) {
        error_code = Error()
        if let meta = meta_ {
            iterator_ = cass_iterator_from_result(meta)
        } else {
            iterator_ = nil
        }
    }
    fileprivate init(valuesFromCollection meta_: OpaquePointer?) {
        error_code = Error()
        if let meta = meta_ {
            iterator_ = cass_iterator_from_collection(meta)
        } else {
            iterator_ = nil
        }
    }
    //fileprivate init(valuesFromTuple tuple_: OpaquePointer?) {
    //    error_code = Error()
    //    if let tuple = tuple_ {
    //        iterator_ = cass_iterator_from_tuple(tuple)
    //    } else {
    //        iterator_ = nil
    //    }
    //}
    //fileprivate init(fieldsFromUserType user_type_: OpaquePointer?) {
    //    error_code = Error()
    //    if let user_type = user_type_ {
    //        iterator_ = cass_iterator_fields_from_user_type(user_type)
    //    } else {
    //        iterator_ = nil
    //    }
    //}
    fileprivate init(itemsFromMap meta_: OpaquePointer?) {
        error_code = Error()
        if let meta = meta_ {
            iterator_ = cass_iterator_from_map(meta)
        } else {
            iterator_ = nil
        }
    }
    fileprivate init(fieldsFromKeyspaceMeta meta_: OpaquePointer?) {
        error_code = Error()
        if let meta = meta_ {
            iterator_ = cass_iterator_fields_from_keyspace_meta(meta )
        } else {
            iterator_ = nil
        }
    }
    fileprivate init(fieldsFromAggregateMeta meta_: OpaquePointer?) {
        error_code = Error()
        if let meta = meta_ {
            iterator_ = cass_iterator_fields_from_aggregate_meta(meta)
        } else {
            iterator_ = nil
        }
    }
    fileprivate init(fieldsFromTableMeta meta_: OpaquePointer?) {
        error_code = Error()
        if let meta = meta_ {
            iterator_ = cass_iterator_fields_from_table_meta(meta)
        } else {
            iterator_ = nil
        }
    }
    fileprivate init(fieldsFromFunctionMeta meta_: OpaquePointer?) {
        error_code = Error()
        if let meta = meta_ {
            iterator_ = cass_iterator_fields_from_function_meta(meta)
        } else {
            iterator_ = nil
        }
    }
    fileprivate init(fieldsFromColumnMeta meta_: OpaquePointer?) {
        error_code = Error()
        if let meta = meta_ {
            iterator_ = cass_iterator_fields_from_column_meta(meta)
        } else {
            iterator_ = nil
        }
    }
    fileprivate init(tablesFromKeyspaceMeta meta_: OpaquePointer?) {
        error_code = Error()
        if let meta = meta_ {
            iterator_ = cass_iterator_tables_from_keyspace_meta(meta)
        } else {
            iterator_ = nil
        }
    }
    fileprivate init(functionsFromKeyspaceMeta meta_: OpaquePointer?) {
        error_code = Error()
        if let meta = meta_ {
            iterator_ = cass_iterator_functions_from_keyspace_meta(meta)
        } else {
            iterator_ = nil
        }
    }
    fileprivate init(aggregatesFromKeyspaceMeta meta_: OpaquePointer?) {
        error_code = Error()
        if let meta = meta_ {
            iterator_ = cass_iterator_aggregates_from_keyspace_meta(meta)
        } else {
            iterator_ = nil
        }
    }
    fileprivate init(columnsFromTableMeta meta_: OpaquePointer?) {
        error_code = Error()
        if let meta = meta_ {
            iterator_ = cass_iterator_columns_from_table_meta(meta)
        } else {
            iterator_ = nil
        }
    }
    fileprivate init(indexesFromTableMeta meta_: OpaquePointer?) {
        error_code = Error()
        if let meta = meta_ {
            iterator_ = cass_iterator_indexes_from_table_meta(meta)
        } else {
            iterator_ = nil
        }
    }
    fileprivate init(materializedViewsFromTableMeta meta_: OpaquePointer?) {
        error_code = Error()
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
                let val = Value(cass_iterator_get_map_value(iterator_!))
                return (key: key, value: val?.any)
            }
        }
        return nil
    }
    //var tuple: Tuple.Element {
    //    if let val = value {
    //        print("tuple: \(val)")
    //        return val.anyHashable
    //    }
    //    return nil
    //}
    //var keyValueField: UserType.Element? {
    //    if hasNext() {
    //        if let iterator = iterator_ {
    //            if let str = String(f: cass_iterator_get_user_type_field_name, ptr: iterator) {
    //                if let val = Value(cass_iterator_get_user_type_field_value(iterator)) {
    //                    return (name: str, value: val.anyHashable)
    //                } else {
    //                    return (name: str, value: nil)
    //                }
    //            }
    //        }
    //    }
    //    return nil
    //}
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
            if let str = String(function: cass_iterator_get_meta_field_name, ptr: iterator_!) {
                return (name: str, value: Value(cass_iterator_get_meta_field_value(iterator_!))?.any)
            }
        }
        return nil
    }
    var type: CassIteratorType {
        return cass_iterator_type(iterator_!)
    }
}

public
class ResultIterator: Iterator, Sequence, IteratorProtocol {
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

//public class TupleIterator: Iterator, Sequence, IteratorProtocol {
//    public typealias Element = Tuple.Element
//    init(_ tuple: OpaquePointer) {
//        super.init(valuesFromTuple: tuple)
//    }
//    public func next() -> Tuple.Element? {
//        return tuple
//    }
//}

//public class UserTypeIterator: Iterator, Sequence, IteratorProtocol {
//    public typealias Element = UserType.Element
//    init(_ user_type: OpaquePointer) {
//        super.init(fieldsFromUserType: user_type)
//    }
//    public func next() -> UserType.Element? {
//        return keyValueField
//    }
//}

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

