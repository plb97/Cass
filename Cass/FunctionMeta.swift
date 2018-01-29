//
//  FunctionMeta.swift
//  Cass
//
//  Created by Philippe on 22/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public
class FunctionMeta {
    public struct ArgumentCollection: Collection {
        let functionMeta: FunctionMeta
        init(_ functionMeta: FunctionMeta) {
            self.functionMeta = functionMeta
        }
        // minimum requis pour satisfaire le protocole 'Collection'
        public typealias Element = (name: String, type: DataType)
        public var startIndex: Int { return 0 }
        public var endIndex: Int   { return cass_function_meta_argument_count(functionMeta.function_meta) }
        public func index(after i: Int) -> Int {
            precondition(i < endIndex, "Can't advance beyond endIndex")
            return i + 1
        }
        public subscript(index: Int) -> Element {
            get {
                precondition(0 <= index && index < endIndex, "index out of bounds")
                var name: UnsafePointer<Int8>?
                var name_length: Int = 0
                var type : OpaquePointer?
                let rc = cass_function_meta_argument(functionMeta.function_meta, index, &name, &name_length, &type)
                if CASS_OK == rc {
                    if let str = String(ptr: name, len: name_length) {
                        return (name: str, type: DataType(type))
                    }
                }
                fatalError(FATAL_ERROR_MESSAGE)
            }
        }
    }
    public struct ArgumentTypeSubscript {
        let functionMeta: FunctionMeta
        init(_ functionMeta: FunctionMeta) {
            self.functionMeta = functionMeta
        }
        public typealias Element = DataType?
        public subscript(name: String) -> Element {
            get {
                return DataType(cass_function_meta_argument_type_by_name(functionMeta.function_meta, name))
            }
        }
    }
    public struct FieldSubscript {
        let functionMeta: FunctionMeta
        init(_ functionMeta: FunctionMeta) {
            self.functionMeta = functionMeta
        }
        public typealias Element = Value?
        public subscript(name: String) -> Element {
            get {
                return Value(cass_function_meta_field_by_name(functionMeta.function_meta, name))
            }
        }
    }
    let function_meta: OpaquePointer
    lazy public var argument = ArgumentCollection(self)
    lazy public var argumentType = ArgumentTypeSubscript(self)
    lazy public var field = FieldSubscript(self)
    init?(_ function_meta_: OpaquePointer?) {
        if let function_meta = function_meta_ {
            self.function_meta = function_meta
        } else {
            return nil
        }
    }
    public var name: String {
        if let str = String(function: cass_function_meta_name, ptr: function_meta) {
            return str
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    public var fullName: String {
        if let str = String(function: cass_function_meta_full_name, ptr: function_meta) {
            return str
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    public var body: String {
        if let str = String(function: cass_function_meta_body, ptr: function_meta) {
            return str
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    public var language: String {
        if let str = String(function: cass_function_meta_language, ptr: function_meta) {
            return str
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    public var calledOnNullInput: Bool {
        return cass_true == cass_function_meta_called_on_null_input(function_meta )
    }
    public var returnType: DataType {
        return DataType(cass_function_meta_return_type(function_meta))
    }
    public var fields: FieldFunctionIterator {
        return FieldFunctionIterator(function_meta)
    }
    public var argumentCount: Int {
        return cass_function_meta_argument_count(function_meta)
    }
    public func argument(index: Int) -> (name: String, type: DataType) {
        var name: UnsafePointer<Int8>?
        var name_length: Int = 0
        var type : OpaquePointer?
        let rc = cass_function_meta_argument(function_meta, index, &name, &name_length, &type)
        if CASS_OK == rc {
            if let str = String(ptr: name, len: name_length) {
                return (name: str, type: DataType(type))
            }
        }
        fatalError("Ne devrait pas arriver")
    }
    public func argumentType(name: String) -> DataType? {
        return DataType(cass_function_meta_argument_type_by_name(function_meta, name))
    }
    public func field(name: String) -> Value? {
        return Value(cass_function_meta_field_by_name(function_meta, name))
    }

}
