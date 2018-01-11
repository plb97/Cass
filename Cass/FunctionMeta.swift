//
//  FunctionMeta.swift
//  Cass
//
//  Created by Philippe on 22/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public
class FunctionMeta: Status {
    let function_meta: OpaquePointer
    init?(_ function_meta_: OpaquePointer?) {
        if let function_meta = function_meta_ {
            self.function_meta = function_meta
            super.init()
        } else {
            return nil
        }
    }
    public var name: String {
        var name: UnsafePointer<Int8>?
        var name_length: Int = 0
        cass_function_meta_name(function_meta, &name, &name_length)
        if let str = utf8_string(text: name, len: name_length) {
            return str
        } else {
            fatalError("Ne devrait pas arriver")
        }
    }
    public var fullName: String {
        var name: UnsafePointer<Int8>?
        var name_length: Int = 0
        cass_function_meta_full_name(function_meta, &name, &name_length)
        if let str = utf8_string(text: name, len: name_length) {
            return str
        } else {
            fatalError("Ne devrait pas arriver")
        }
    }
    public var body: String {
        var text: UnsafePointer<Int8>?
        var text_length: Int = 0
        cass_function_meta_body(function_meta, &text, &text_length)
        if let str = utf8_string(text: text, len: text_length) {
            return str
        } else {
            fatalError("Ne devrait pas arriver")
        }
    }
    public var language: String {
        var name: UnsafePointer<Int8>?
        var name_length: Int = 0
        cass_function_meta_language(function_meta, &name, &name_length)
        if let str = utf8_string(text: name, len: name_length) {
            return str
        } else {
            fatalError("Ne devrait pas arriver")
        }
    }
    public var calledOnNullInput: Bool {
        return cass_true == cass_function_meta_called_on_null_input(function_meta )
    }
    public var argumentCount: Int {
        return cass_function_meta_argument_count(function_meta)
    }
    public func argument(index: Int) -> (name: String, type: DataType) {
        var name: UnsafePointer<Int8>?
        var name_length: Int = 0
        var type : OpaquePointer?
        msg_ = message(cass_function_meta_argument(function_meta, index, &name, &name_length, &type))
        if let str = utf8_string(text: name, len: name_length) {
            return (name: str, type: DataType(type)!)
        } else {
            fatalError("Ne devrait pas arriver")
        }
    }
    public func argumentType(name: String) -> DataType? {
        return DataType(cass_function_meta_argument_type_by_name(function_meta, name))
    }
    public var returnType: DataType {
        return DataType(cass_function_meta_return_type(function_meta))!
    }
    public func field(name: String) -> Value? {
        return Value(cass_function_meta_field_by_name(function_meta, name))
    }
    public var fields: FieldFunctionIterator {
        return FieldFunctionIterator(function_meta)
    }
}
