//
//  DataType.swift
//  Cass
//
//  Created by Philippe on 22/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public class DataType {
    var error_code: Error
    /*
    public struct SubTypeCollection: Collection {
        let dataType: DataType
        init(_ dataType: DataType) {
            self.dataType = dataType
        }
        // minimum requis pour satisfaire le protocole 'Collection'
        public typealias Element = DataType?
        public var startIndex: Int { return 0 }
        public var endIndex: Int   { return cass_data_type_sub_type_count(dataType.data_type) }
        public func index(after i: Int) -> Int {
            precondition(i < endIndex, "Can't advance beyond endIndex")
            return i + 1
        }
        public subscript(index: Int) -> Element {
            get {
                //precondition(0 <= index && index < endIndex, "index out of bounds")
                return DataType(cass_data_type_sub_data_type(dataType.data_type, index))
            }
        }
        public func append(_ subDataType: Element) {
            let rc = cass_data_type_add_sub_type(dataType.data_type, subDataType?.data_type)
            if CASS_OK != rc {
                fatalError(rc.description) // TODO
            }
        }
        public subscript(name: String) -> Element {
            get {
                return DataType(cass_data_type_sub_data_type_by_name(dataType.data_type, name))
            }
            set (subDataType) {
                let rc = cass_data_type_add_sub_type_by_name(dataType.data_type, name, subDataType?.data_type)
                if CASS_OK != rc {
                    fatalError(rc.description) // TODO
                }
            }
        }
    }
    public class NameSubscript {
        let dataType: DataType
        init(_ dataType: DataType) {
            self.dataType = dataType
        }
        public typealias Element = String?
        public subscript(index: Int) -> Element {
            get {
                return String(f: cass_data_type_sub_type_name, ptr: dataType.data_type, index: index)
            }
        }
    }
    lazy public var nameType = NameSubscript(self)
    lazy public var subType = SubTypeCollection(self)
     */
    let data_type: OpaquePointer
    let must_be_freed: Bool
    init(_ data_type_: OpaquePointer?) {
        error_code = Error()
       if let data_type = data_type_ {
            must_be_freed = false
            self.data_type = data_type
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
            //return nil
        }
    }
    init(fromExisting type: DataType) {
        error_code = Error()
        if let data_type = cass_data_type_new_from_existing(type.data_type) {
            must_be_freed = true
            self.data_type = data_type
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
            //return nil
        }
    }
    init(tuple itemCount: Int) {
        error_code = Error()
        if let data_type = cass_data_type_new_tuple(itemCount) {
            must_be_freed = true
            self.data_type = data_type
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
            //return nil
        }
    }
    init(udt itemCount: Int) {
        error_code = Error()
        if let data_type = cass_data_type_new_udt(itemCount) {
            must_be_freed = true
            self.data_type = data_type
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
            //return nil
        }
    }
    deinit {
        if must_be_freed {
            cass_data_type_free(data_type)
        }
    }
    public var type: ValueType {
        return ValueType(cass_data_type_type(data_type))
    }
    public var isFrozen: Bool {
        return cass_true == cass_data_type_is_frozen(data_type)
    }
    public var name: String {
        get {
            var name: UnsafePointer<Int8>?
            var name_length: Int = 0
            cass_data_type_type_name(data_type, &name, &name_length)
            return String(function: cass_data_type_type_name, ptr: data_type)!
        }
        set (type_name) {
            cass_data_type_set_type_name(data_type, type_name)
        }
    }
    public var keyspace: String {
        get {
            var name: UnsafePointer<Int8>?
            var name_length: Int = 0
            cass_data_type_keyspace(data_type, &name, &name_length)
            return String(function: cass_data_type_keyspace, ptr: data_type)!
        }
        set (keyspace) {
            cass_data_type_set_keyspace(data_type, keyspace)
        }
    }
    public var class_name: String {
        get {
            return String(function: cass_data_type_class_name, ptr: data_type)!
        }
        set (class_name) {
            cass_data_type_set_class_name(data_type, class_name)
        }
    }
    public var subTypeCount: Int {
        return cass_data_type_sub_type_count(data_type)
    }
    public func subDataType(index: Int) -> DataType {
        return DataType(cass_data_type_sub_data_type(data_type, index))
    }
    public func subDataType(name: String) -> DataType? {
        return DataType(cass_data_type_sub_data_type_by_name(data_type, name))
    }
    public func subTypeName(index: Int) -> String {
        return String(function: cass_data_type_sub_type_name, ptr: data_type, index: index)!
    }
    public func addSubType(_ subDataType: DataType) -> DataType {
        error_code = Error(cass_data_type_add_sub_type(data_type, subDataType.data_type))
        return self
    }
    public func addSubType(name: String,_ subDataType: DataType) -> DataType {
        error_code = Error(cass_data_type_add_sub_type_by_name(data_type, name, subDataType.data_type))
        return self
    }
    func addSubValueType(_ subValueType: CassValueType) -> DataType {
        error_code = Error(cass_data_type_add_sub_value_type(data_type, subValueType))
        return self
    }
    func addSubValueType(name: String,_ subValueType: CassValueType) -> DataType {
        error_code = Error(cass_data_type_add_sub_value_type_by_name(data_type, name, subValueType))
        return self
    }
}
