//
//  DataType.swift
//  Cass
//
//  Created by Philippe on 22/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public
class DataType: Status {
    let data_type: OpaquePointer
    init?(_ data_type_: OpaquePointer?) {
        if let data_type = data_type_ {
            self.data_type = data_type
        } else {
            return nil
        }
    }
    init(fromExisting type: DataType) {
        data_type = cass_data_type_new_from_existing(type.data_type)
    }
    init(tuple itemCount: Int) {
        data_type = cass_data_type_new_tuple(itemCount)
    }
    init(udt itemCount: Int) {
        data_type = cass_data_type_new_udt(itemCount)
    }
    deinit {
        defer {
            cass_data_type_free(data_type)
        }
    }
    var type: CassValueType {
        return cass_data_type_type(data_type)
    }
    public var isFrozen: Bool {
        return cass_true == cass_data_type_is_frozen(data_type)
    }
    public var name: String {
        get {
            var name: UnsafePointer<Int8>?
            var name_length: Int = 0
            cass_data_type_type_name(data_type, &name, &name_length)
            return utf8_string(text: name, len: name_length)!
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
            return utf8_string(text: name, len: name_length)!
        }
        set (keyspace) {
            cass_data_type_set_keyspace(data_type, keyspace)
        }
    }
    public var class_name: String {
        get {
            var name: UnsafePointer<Int8>?
            var name_length: Int = 0
            cass_data_type_class_name(data_type, &name, &name_length)
            return utf8_string(text: name, len: name_length)!
        }
        set (class_name) {
            cass_data_type_set_class_name(data_type, class_name)
        }
    }
    public var subTypeCount: Int {
        return cass_data_type_sub_type_count(data_type)
    }
    public func subDataType(index: Int) -> DataType {
        return DataType(cass_data_type_sub_data_type(data_type, index))!
    }
    public func subDataType(name: String) -> DataType? {
        return DataType(cass_data_type_sub_data_type_by_name(data_type, name))
    }
    public func subTypeName(index: Int) -> String {
        var name: UnsafePointer<Int8>?
        var name_length: Int = 0
        cass_data_type_sub_type_name(data_type, index, &name, &name_length)
        return utf8_string(text: name, len: name_length)!
    }
    public func addSubType(_ subDataType: DataType) -> DataType {
        msg_ = message(cass_data_type_add_sub_type(data_type, subDataType.data_type))
        return self
    }
    public func addSubType(name: String,_ subDataType: DataType) -> DataType {
        msg_ = message(cass_data_type_add_sub_type_by_name(data_type, name, subDataType.data_type))
        return self
    }
    func addSubValueType(_ subValueType: CassValueType) -> DataType {
        msg_ = message(cass_data_type_add_sub_value_type(data_type, subValueType))
        return self
    }
    func addSubValueType(name: String,_ subValueType: CassValueType) -> DataType {
        msg_ = message(cass_data_type_add_sub_value_type_by_name(data_type, name, subValueType))
        return self
    }
}
