//
//  Tuple.swift
//  Cass
//
//  Created by Philippe on 27/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//
public class Tuple: MutableCollection, Hashable, CustomStringConvertible {
    public typealias Element = Any?
    var error_code_: Error? = nil
    var array: Array<Element>
    var tuple_: OpaquePointer?
    public init(count: Int) {
        self.array = Array(repeating: nil, count: count)
    }
    public init(_ values: Element...) {
        self.array = Array(values)
    }
    private static func toArray(tuple: OpaquePointer) -> Array<Tuple.Element> {
        var array = Array<Tuple.Element>()
        let iterator_ = cass_iterator_from_tuple(tuple)
        if let iterator = iterator_ {
            while cass_true == cass_iterator_next(iterator) {
                let value_ = Value(cass_iterator_get_value(iterator))
                array.append(value_?.anyHashable)
            }
        }
        return array
    }
    init(cass tuple: OpaquePointer) {
        // ATTENTION : ne pas conserver 'tuple' pour ne pas appeler 'cass_tuple_free' dans 'deinit'
        self.array = Tuple.toArray(tuple: tuple)
    }
    init(dataType: DataType) {
        // ATTENTION : il faut conserver 'tuple' pour appeler 'cass_tuple_free' dans 'deinit'
        if let tuple = cass_tuple_new_from_data_type(dataType.data_type) {
            self.tuple_ = tuple
            self.array = Tuple.toArray(tuple: tuple)
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    deinit {
        if let tuple = tuple_ {
            cass_tuple_free(tuple)
        }
    }
    public var description: String {
        return "tuple\(String(describing: tuple_)) \(array.description)"
    }
    var cass: OpaquePointer {
        if let tuple = tuple_ {
            return tuple
        } else {
            if let tuple = cass_tuple_new(array.count) {
                print("new tuple \(tuple)")
                let rc = set_lst(tuple, lst: array)
                if CASS_OK == rc {
                    tuple_ = tuple
                    return tuple
                }
            }
        }
        fatalError(FATAL_ERROR_MESSAGE)
    }
    public var dataType: DataType {
        if let tuple = cass_tuple_new(array.count) {
            let rc = set_lst(tuple, lst: array)
            if CASS_OK == rc {
                return DataType(cass_tuple_data_type(tuple))
            }
        }
        fatalError(FATAL_ERROR_MESSAGE)
    }
    
    // minimum requis pour satisfaire le protocole 'Collection'
    public var startIndex: Int { return 0 }
    public var endIndex: Int   { return array.count }
    public func index(after index: Int) -> Int {
        precondition(0 <= index && index < array.count, "index out of bounds")
        return index + 1
    }
    public subscript(index: Int) -> Element {
        get {
            precondition(0 <= index && index < array.count, "index out of bounds")
            return array[index]
        }
        set (newValue) {
            precondition(0 <= index && index < array.count, "index out of bounds")
            array[index] = newValue
        }
    }
    public var hashValue: Int {
        var hash = 5381
        for i in 0..<self.array.count {
            if let val = self.array[i] as? AnyHashable {
                hash = ((hash << 5) &+ hash) &+ val.hashValue
            } else {
                hash = ((hash << 5) &+ hash)
            }
        }
        return hash
    }
    public static func ==(lhs: Tuple, rhs: Tuple) -> Bool {
        return lhs.array.elementsEqual(rhs.array, by:
            {(le_: Element, re_: Element) -> Bool in
                return le_ is AnyHashable
                && re_ is AnyHashable
                && le_ as? AnyHashable == re_ as? AnyHashable

        }
        )
    }




    @discardableResult
    private func setNull(_ index: Int) -> Tuple {
        if let tuple = tuple_ {
            error_code_ = Error(cass_tuple_set_null(tuple, index))
        }
        return self
    }
    @discardableResult
    private func setInt8(_ index: Int, value: Int8) -> Tuple {
        if let tuple = tuple_ {
            error_code_ = Error(cass_tuple_set_int8(tuple, index, value))
        }
        return self
    }
    @discardableResult
    private func setInt16(_ index: Int, value: Int16) -> Tuple {
        if let tuple = tuple_ {
            error_code_ = Error(cass_tuple_set_int16(tuple, index, value))
        }
        return self
    }
    @discardableResult
    private func setInt32(_ index: Int, value: Int32) -> Tuple {
        if let tuple = tuple_ {
            error_code_ = Error(cass_tuple_set_int32(tuple, index, value))
        }
        return self
    }
    @discardableResult
    private func setUInt32(_ index: Int, value: UInt32) -> Tuple {
        if let tuple = tuple_ {
            error_code_ = Error(cass_tuple_set_uint32(tuple, index, value))
        }
        return self
    }
    @discardableResult
    private func setInt64(_ index: Int, value: Int64) -> Tuple {
        if let tuple = tuple_ {
            error_code_ = Error(cass_tuple_set_int64(tuple, index, value))
        }
        return self
    }
    @discardableResult
    private func setFloat(_ index: Int, value: Float) -> Tuple {
        if let tuple = tuple_ {
            error_code_ = Error(cass_tuple_set_float(tuple, index, value))
        }
        return self
    }
    @discardableResult
    private func setDouble(_ index: Int, value: Double) -> Tuple {
        if let tuple = tuple_ {
            error_code_ = Error(cass_tuple_set_double(tuple, index, value))
        }
        return self
    }
    @discardableResult
    private func setBool(_ index: Int, value: Bool) -> Tuple {
        if let tuple = tuple_ {
            error_code_ = Error(cass_tuple_set_bool(tuple, index, value ? cass_true : cass_false))
        }
        return self
    }
    @discardableResult
    private func setString(_ index: Int, value: String) -> Tuple {
        if let tuple = tuple_ {
            error_code_ = Error(cass_tuple_set_string(tuple, index, value))
        }
        return self
    }
    @discardableResult
    private func setBytes(_ index: Int, value: BLOB) -> Tuple {
        if let tuple = tuple_ {
            error_code_ = Error(cass_tuple_set_bytes(tuple, index, value.array, value.array.count))
        }
        return self
    }
    @discardableResult
    private func setUuid(_ index: Int, value: UUID) -> Tuple {
        if let tuple = tuple_ {
            error_code_ = Error(cass_tuple_set_uuid(tuple, index, value.cass))
        }
        return self
    }
    @discardableResult
    private func setInet(_ index: Int, value: Inet) -> Tuple {
        if let tuple = tuple_ {
            error_code_ = Error(cass_tuple_set_inet(tuple, index, value.cass))
        }
        return self
    }
    @discardableResult
    private func setDecimal(_ index: Int, value: Decimal) -> Tuple {
        if let tuple = tuple_ {
            let (varint, varint_size, scale) = value.cass
            error_code_ = Error(cass_tuple_set_decimal(tuple, index, varint, varint_size, scale))
        }
        return self
    }
    @discardableResult
    private func setDuration(_ index: Int, value: Duration) -> Tuple {
        if let tuple = tuple_ {
            error_code_ = Error(cass_tuple_set_duration(tuple, index, value.months, value.days, value.nanos))
        }
        return self
    }
    @discardableResult
    private func setTuple(_ index: Int, value: Tuple) -> Tuple {
        if let tuple = tuple_ {
            error_code_ = Error(cass_tuple_set_tuple(tuple, index, value.cass))
        }
        return self
    }
    @discardableResult
    private func setUserType(_ index: Int, value: UserType) -> Tuple {
        if let tuple = tuple_ {
            error_code_ = Error(cass_tuple_set_user_type(tuple, index, value.cass))
        }
        return self
    }
    @discardableResult
    private func setCollection(_ index: Int,_ value: LIST) -> Tuple {
        if let tuple = tuple_ {
            let collection = value.cass
            defer {
                cass_collection_free(collection)
            }
            error_code_ = Error(cass_tuple_set_collection(tuple, index, collection))
        }
        return self
    }
    @discardableResult
    private func setCollection(_ index: Int,_ value: SET) -> Tuple {
        if let tuple = tuple_ {
            let collection = value.cass
            defer {
                cass_collection_free(collection)
            }
            error_code_ = Error(cass_tuple_set_collection(tuple, index, collection))
        }
        return self
    }
    @discardableResult
    private func setCollection(_ index: Int,_ value: MAP) -> Tuple {
        if let tuple = tuple_ {
            let collection = value.cass
            defer {
                cass_collection_free(collection)
            }
            error_code_ = Error(cass_tuple_set_collection(tuple, index, collection))
        }
        return self
    }
}

fileprivate func set_lst(_ tuple: OpaquePointer, lst: [Any?]) -> CassError {
    var rc = CASS_OK
    for (idx,value) in lst.enumerated() {
        if CASS_OK != rc {
            break
        }
        switch value {
        case nil:
            rc = cass_tuple_set_null(tuple, idx)

        case let v as BLOB:
            let (ptr, len) = v.cass
            rc = cass_tuple_set_bytes(tuple, idx, ptr, len)
        case let v as SET:
            let collection = v.cass
            defer {
                cass_collection_free(collection)
            }
            rc = cass_tuple_set_collection(tuple, idx, collection)
        case let v as LIST:
            let collection = v.cass
            defer {
                cass_collection_free(collection)
            }
            rc = cass_tuple_set_collection(tuple, idx, collection)
        case let v as MAP:
            let collection = v.cass
            defer {
                cass_collection_free(collection)
            }
            rc = cass_tuple_set_collection(tuple, idx, collection)

        case let v as String:
            let (ptr, len) = v.cass
            rc = cass_tuple_set_string_n(tuple, idx, ptr, len)
        case let v as Bool:
            rc = cass_tuple_set_bool(tuple, idx, v.cass)
        case let v as Float:
            rc = cass_tuple_set_float(tuple, idx, v.cass)
        case let v as Double:
            rc = cass_tuple_set_double(tuple, idx, v.cass)
        case let v as Int8:
            rc = cass_tuple_set_int8(tuple, idx, v.cass)
        case let v as Int16:
            rc = cass_tuple_set_int16(tuple, idx, v.cass)
        case let v as Int32:
            rc = cass_tuple_set_int32(tuple, idx, v.cass)
        case let v as Int:
            rc = cass_tuple_set_int32(tuple, idx, v.cass)
        case let v as UInt32:
            rc = cass_tuple_set_uint32(tuple, idx, v.cass)
        case let v as UInt:
            rc = cass_tuple_set_uint32(tuple, idx, v.cass)
        case let v as Int64:
            rc = cass_tuple_set_int64(tuple, idx, v.cass)
        case let v as Inet:
            rc = cass_tuple_set_inet(tuple, idx, v.cass)
        case let v as UUID:
            rc = cass_tuple_set_uuid(tuple, idx, v.cass)
        case let v as Date:
            rc = cass_tuple_set_int64(tuple, idx, v.cass)
        case let v as Duration:
            let (months, days, nanos) = v.cass
            rc = cass_tuple_set_duration(tuple, idx, months, days, nanos)
        case let v as Decimal:
            let (varint, varint_size, int32) = v.cass
            rc = cass_tuple_set_decimal(tuple, idx, varint, varint_size, int32)

        case let v as Tuple:
            rc = cass_tuple_set_tuple(tuple, idx, v.cass)
        case let v as UserType:
            rc = cass_tuple_set_user_type(tuple, idx, v.cass)

        default:
            print("*** Tuple set_lst: Invalid argument: index=\(idx), type of=\(type(of:value!)), Any=\(value!)")
            rc = CASS_ERROR_LIB_INVALID_VALUE_TYPE
        }
    }
    return rc
}

// autre approche possible...
/*
typealias TupleArray = Array<Any?>
extension Array where Array.Element == Any?  {
    public init(count: Int) {
        self.init(repeating: nil, count: count)
    }
    public init(_ values: Any?...) {
        self.init(values)
    }
    init(tuple: OpaquePointer) {
        print("init Tuple \(tuple)")
        // ATTENTION : ne pas conserver 'tuple' pour ne pas appeler 'cass_tuple_free(tuple)' dans 'deinit'
        self.init()
        for v in TupleIterator(tuple) {
            self.append(v)
        }
    }
    public init(dataType: DataType) {
        self.init(tuple: cass_tuple_new_from_data_type(dataType.data_type))
    }
    // ATTENTION : c'est la responsabilite de l'appelant de liberer le 'tuple' avec 'cass_tuple_free(tuple)'
    var tuple: OpaquePointer {
        let res = cass_tuple_new(self.count)!
        let rc = set_lst(res, lst: self)
        if CASS_OK == rc {
            return res
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    // REMARQUE : il ne faut pas liberer le 'tuple' associe au dataType
    public var dataType: DataType {
        return DataType(cass_tuple_data_type(self.tuple))!
    }
}
*/

//extension Array: Equatable where Element: Equatable {
//    static func ==(lhs: Array<Element>, rhs: Array<Element>) -> Bool { return false }
//}
