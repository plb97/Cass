//
//  Udt.swift
//  Cass
//
//  Created by Philippe on 15/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

public class UserType: MutableCollection, Hashable, CustomStringConvertible {
    public typealias Element = (name: String, value: Any?)?
    var array: Array<Element>
    var error_code: Error
    var user_type_: OpaquePointer?
    let must_be_freed: Bool
    var dataType: DataType
    private static func toArray(user_type: OpaquePointer) -> Array<UserType.Element> {
        var array = Array<UserType.Element>()
        let iterator_ = cass_iterator_fields_from_user_type(user_type)
        if let iterator = iterator_ {
            while cass_true == cass_iterator_next(iterator) {
                if let str = String(function: cass_iterator_get_user_type_field_name, ptr: iterator) {
                    if let val = Value(cass_iterator_get_user_type_field_value(iterator)) {
                        array.append((name: str, value: val.anyHashable))
                    } else {
                        array.append((name: str, value: nil))
                    }
                } else {
                    array.append(nil)
                }
            }
        }
        return array
    }

    public init(dataType: DataType, count: Int = 0) {
        error_code = Error()
        self.dataType = dataType
        self.array = Array(repeating: nil, count: count)
        self.must_be_freed = true
    }
    public init(dataType: DataType,_ values: Element...) {
        error_code = Error()
        self.dataType = dataType
        self.array = Array(values)
        self.must_be_freed = true
    }
    init(cass user_type: OpaquePointer) {
        error_code = Error()
        self.user_type_ = user_type
        self.must_be_freed = false
        if let data_type = cass_user_type_data_type(user_type) {
            let dataType = DataType(data_type)
            self.dataType = dataType
            self.array = UserType.toArray(user_type: user_type)
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    deinit {
        if must_be_freed, let user_type = user_type_ {
            cass_user_type_free(user_type)
        }
    }
    public var description: String {
        return "user_type \(String(describing: user_type_)) \(array)"
    }

    public var startIndex: Int = 0
    public var endIndex: Int { return array.count }
    public func index(after index: Int) -> Int {
        precondition(index < endIndex, "Can't advance beyond endIndex")
        return index + 1
    }
    public subscript(index: Int) -> Element {
        get {
            precondition(startIndex <= index && index < endIndex, "index out of bounds")
            return array[index]
        }
        set (newValue) {
            precondition(startIndex <= index && index < endIndex, "index out of bounds")
            array[index] = newValue
        }
    }

    public subscript(name: String) -> Any? {
        get {
            for element_ in array {
                if let element = element_ {
                    if name == element.name {
                        return element.value
                    }
                }
            }
            return nil
        }
        set (newValue) {
            for (index, element_) in array.enumerated() {
                if let element = element_ {
                    if name == element.name {
                        array[index] = (name, newValue)
                        return
                    }
                }
            }
            array.append((name,newValue))
        }
    }
    public func append(_ newElement: Element) {
        array.append(newElement)
    }
    public func remove(at index: Int) {
        array.remove(at: index)
    }
    public var names: Array<String> {
        var res = Array<String>()
        for element_ in array {
            if let element = element_ {
                res.append(element.name)
            }
        }
        return res
    }
    public var hashValue: Int {
        var hash = 5381
        for element in array {
            if let name = element?.name {
                hash = ((hash << 5) &+ hash) &+ name.hashValue
            }
            if let val = element?.value as? AnyHashable {
                hash = ((hash << 5) &+ hash) &+ val.hashValue
            }
        }
        return hash
    }
    public static func ==(lhs: UserType, rhs: UserType) -> Bool {
        let ctr = lhs.array.count
        if ctr != rhs.array.count {
            return false
        }
        for i in 0..<ctr {
            let le = lhs.array[i]
            let re = rhs.array[i]
            if !(le?.name == re?.name
                && le?.value is AnyHashable
                && re?.value is AnyHashable
                && le?.value as? AnyHashable == re?.value as? AnyHashable) {
                return false
            }
        }
        return true
    }
    var cass: OpaquePointer {
        if let user_type = user_type_ {
            return user_type
        } else {
            if let user_type = cass_user_type_new_from_data_type(dataType.data_type) {
                let rc = set_lst(user_type, lst: array)
                if CASS_OK == rc {
                    user_type_ = user_type
                    return user_type
                }
            }
        }
        fatalError(FATAL_ERROR_MESSAGE)
    }
    @discardableResult
    private func setNull(_ index: Int) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_null(user_type, index))
        }
        return self
    }
    @discardableResult
    private func setNull(name: String) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_null_by_name(user_type, name))
        }
        return self
    }
    @discardableResult
    private func setInt8(_ index: Int,_ value: Int8) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_int8(user_type, index, value))
        }
        return self
    }
    @discardableResult
    private func setInt8(name: String,_ value: Int8) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_int8_by_name(user_type, name, value))
        }
        return self
    }
    @discardableResult
    private func setInt16(_ index: Int,_ value: Int16) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_int16(user_type, index, value))
        }
        return self
    }
    @discardableResult
    private func setInt16(name: String,_ value: Int16) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_int16_by_name(user_type, name, value))
        }
        return self
    }
    @discardableResult
    private func setInt32(_ index: Int,_ value: Int32) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_int32(user_type, index, value))
        }
        return self
    }
    @discardableResult
    private func setInt32(name: String,_ value: Int32) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_int32_by_name(user_type, name, value))
        }
        return self
    }
    @discardableResult
    private func setUInt32(_ index: Int,_ value: UInt32) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_uint32(user_type, index, value))
        }
        return self
    }
    @discardableResult
    private func setUInt32(name: String,_ value: UInt32) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_uint32_by_name(user_type, name, value))
        }
        return self
    }
    @discardableResult
    private func setInt64(_ index: Int,_ value: Int64) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_int64(user_type, index, value))
        }
        return self
    }
    @discardableResult
    private func setInt64(name: String,_ value: Int64) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_int64_by_name(user_type, name, value))
        }
        return self
    }
    @discardableResult
    private func setFloat(_ index: Int,_ value: Float) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_float(user_type, index, value))
        }
        return self
    }
    @discardableResult
    private func setFloat(name: String,_ value: Float) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_float_by_name(user_type, name, value))
        }
        return self
    }
    @discardableResult
    private func setDouble(_ index: Int,_ value: Double) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_double(user_type, index, value))
        }
        return self
    }
    @discardableResult
    private func setDouble(name: String,_ value: Double) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_double_by_name(user_type, name, value))
        }
        return self
    }
    @discardableResult
    private func setBool(_ index: Int,_ value: Bool) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_bool(user_type, index, value ? cass_true : cass_false))
        }
        return self
    }
    @discardableResult
    private func setBool(name: String,_ value: Bool) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_bool_by_name(user_type, name, value ? cass_true : cass_false))
        }
        return self
    }
    @discardableResult
    private func setString(_ index: Int,_ value: String) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_string(user_type, index, value))
        }
        return self
    }
    @discardableResult
    private func setString(name: String,_ value: String) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_string_by_name(user_type, name, value))
        }
        return self
    }
    @discardableResult
    private func setBytes(_ index: Int,_ value: BLOB) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_bytes(user_type, index, value.array, value.array.count))
        }
        return self
    }
    @discardableResult
    private func setBytes(name: String,_ value: BLOB) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_bytes_by_name(user_type, name, value.array, value.array.count))
        }
        return self
    }
    @discardableResult
    private func setUuid(_ index: Int,_ value: UUID) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_uuid(user_type, index, value.cass))
        }
        return self
    }
    @discardableResult
    private func setUuid(name: String,_ value: UUID) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_uuid_by_name(user_type, name, value.cass))
        }
        return self
    }
    @discardableResult
    private func setInet(_ index: Int,_ value: Inet) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_inet(user_type, index, value.cass))
        }
        return self
    }
    @discardableResult
    private func setInet(name: String,_ value: Inet) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_inet_by_name(user_type, name, value.cass))
        }
        return self
    }
    @discardableResult
    private func setDecimal(_ index: Int,_ value: Decimal) -> UserType {
        if let user_type = user_type_ {
            let (varint, varint_size, scale) = value.cass
            error_code = Error(cass_user_type_set_decimal(user_type, index, varint, varint_size, scale))
        }
        return self
    }
    @discardableResult
    private func setDecimal(name: String,_ value: Decimal) -> UserType {
        if let user_type = user_type_ {
            let (varint, varint_size, scale) = value.cass
            error_code = Error(cass_user_type_set_decimal_by_name(user_type, name, varint, varint_size, scale))
        }
        return self
    }
    @discardableResult
    private func setDuration(_ index: Int,_ value: Duration) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_duration(user_type, index, value.months, value.days, value.nanos))
        }
        return self
    }
    @discardableResult
    private func setDuration(name: String,_ value: Duration) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_duration_by_name(user_type, name, value.months, value.days, value.nanos))
        }
        return self
    }
    @discardableResult
    private func setTuple(_ index: Int,_ value: Tuple) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_tuple(user_type, index, value.cass))
        }
        return self
    }
    @discardableResult
    private func setTuple(name: String,_ value: Tuple) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_tuple_by_name(user_type, name, value.cass))
        }
        return self
    }
    @discardableResult
    private func setUserType(_ index: Int,_ value: UserType) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_user_type(user_type, index, value.cass))
        }
        return self
    }
    @discardableResult
    private func setUserType(name: String,_ value: UserType) -> UserType {
        if let user_type = user_type_ {
            error_code = Error(cass_user_type_set_user_type_by_name(user_type, name, value.cass))
        }
        return self
    }
    @discardableResult
    private func setCollection(_ index: Int,_ value: SET) -> UserType {
        if let user_type = user_type_ {
            let collection = value.cass
            defer {
                cass_collection_free(collection)
            }
            error_code = Error(cass_user_type_set_collection(user_type, index, collection))
        }
        return self
    }
    @discardableResult
    private func setCollection(name: String,_ value: SET) -> UserType {
        if let user_type = user_type_ {
            let collection = value.cass
            defer {
                cass_collection_free(collection)
            }
            error_code = Error(cass_user_type_set_collection_by_name(user_type, name, collection))
        }
        return self
    }
    @discardableResult
    private func setCollection(_ index: Int,_ value: LIST) -> UserType {
        if let user_type = user_type_ {
            let collection = value.cass
            defer {
                cass_collection_free(collection)
            }
            error_code = Error(cass_user_type_set_collection(user_type, index, collection))
        }
        return self
    }
    @discardableResult
    private func setCollection(name: String,_ value: LIST) -> UserType {
        if let user_type = user_type_ {
            let collection = value.cass
            defer {
                cass_collection_free(collection)
            }
            error_code = Error(cass_user_type_set_collection_by_name(user_type, name, collection))
        }
        return self
    }
    @discardableResult
    private func setCollection(_ index: Int,_ value: MAP) -> UserType {
        if let user_type = user_type_ {
            let collection = value.cass
            defer {
                cass_collection_free(collection)
            }
            error_code = Error(cass_user_type_set_collection(user_type, index, collection))
        }
        return self
    }
    @discardableResult
    private func setCollection(name: String,_ value: MAP) -> UserType {
        if let user_type = user_type_ {
            let collection = value.cass
            defer {
                cass_collection_free(collection)
            }
            error_code = Error(cass_user_type_set_collection_by_name(user_type, name, collection))
        }
        return self
    }
}

fileprivate func set_lst(_ user_type: OpaquePointer, lst: [UserType.Element]) -> CassError {
    var rc = CASS_OK
    for element_ in lst {
        if let element = element_ {
            if CASS_OK != rc {
                break
            }
            let nam = element.name
            if let val = element.value {
                switch val {
                case let v as BLOB:
                    let (ptr, len) = v.cass
                    rc = cass_user_type_set_bytes_by_name(user_type, nam, ptr, len)
                case let v as SET:
                    let collection = v.cass
                    defer {
                        cass_collection_free(collection)
                    }
                    rc = cass_user_type_set_collection_by_name(user_type, nam, collection)
                case let v as LIST:
                    let collection = v.cass
                    defer {
                        cass_collection_free(collection)
                    }
                    rc = cass_user_type_set_collection_by_name(user_type, nam, collection)
                case let v as MAP:
                    let collection = v.cass
                    defer {
                        cass_collection_free(collection)
                    }
                    rc = cass_user_type_set_collection_by_name(user_type, nam, collection)

                case let v as String:
                    //let (nam_ptr, nam_len) = nam.cass
                    //let (ptr, len) = v.cass
                    //rc = cass_user_type_set_string_by_name_n(user_type, nam_ptr, nam_len, ptr, len)
                    rc = cass_user_type_set_string_by_name(user_type, nam, v)
                case let v as Bool:
                    rc = cass_user_type_set_bool_by_name(user_type, nam, v.cass)
                case let v as Float:
                    rc = cass_user_type_set_float_by_name(user_type, nam, v.cass)
                case let v as Double:
                    rc = cass_user_type_set_double_by_name(user_type, nam, v.cass)
                case let v as Int8:
                    rc = cass_user_type_set_int8_by_name(user_type, nam, v.cass)
                case let v as Int16:
                    rc = cass_user_type_set_int16_by_name(user_type, nam, v.cass)
                case let v as Int32:
                    rc = cass_user_type_set_int32_by_name(user_type, nam, v.cass)
                case let v as Int:
                    rc = cass_user_type_set_int32_by_name(user_type, nam, v.cass)
                case let v as UInt32:
                    rc = cass_user_type_set_uint32_by_name(user_type, nam, v.cass)
                case let v as Int64:
                    rc = cass_user_type_set_int64_by_name(user_type, nam, v.cass)
                case let v as Inet:
                    rc = cass_user_type_set_inet_by_name(user_type, nam, v.cass)
                case let v as UUID:
                    rc = cass_user_type_set_uuid_by_name(user_type, nam, v.cass)
                case let v as Date:
                    rc = cass_user_type_set_int64_by_name(user_type, nam, v.cass)
                case let v as Duration:
                    let (months, days, nanos) = v.cass
                    rc = cass_user_type_set_duration_by_name(user_type, nam, months, days, nanos)
                case let v as Decimal:
                    let (varint, varint_size, int32) = v.cass
                    rc = cass_user_type_set_decimal_by_name(user_type, nam, varint, varint_size, int32)

                case let v as Tuple:
                    rc = cass_user_type_set_tuple_by_name(user_type, nam, v.cass)
                case let v as UserType:
                    rc = cass_user_type_set_user_type_by_name(user_type, nam, v.cass)

                default:
                    print("*** UserType set_lst: Invalid argument: index=\(nam), type of=\(type(of:val)), Any=\(val)")
                    rc = CASS_ERROR_LIB_INVALID_VALUE_TYPE
                }
            } else {
                rc = cass_user_type_set_null_by_name(user_type, nam)
            }
        }
    }
    return rc
}
