//
//  Tuple.swift
//  Cass
//
//  Created by Philippe on 27/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//
public class Tuple: Collection {
    public typealias Element = Any?
    var array: Array<Element>
    var tuple_: OpaquePointer?
    public init(count: Int) {
        self.array = Array(repeating: nil, count: count)
    }
    public init(_ values: Element...) {
        self.array = Array(values)
    }
    init(tuple: OpaquePointer) {
        // ATTENTION : ne pas conserver 'tuple' pour ne pas appeler cass_tuple_free dans 'deinit'
        self.array = Array()
        for v in TupleIterator(tuple) {
            self.array.append(v)
        }
    }
    init(dataType: DataType) {
        if let tuple = cass_tuple_new_from_data_type(dataType.data_type) {
            self.tuple_ = tuple
            self.array = Array()
            for v in TupleIterator(tuple) {
                self.array.append(v)
            }
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    deinit {
        if let tuple = tuple_ {
            cass_tuple_free(tuple)
        }
    }
    var tuple: OpaquePointer {
        print("tuple_ \(String(describing: tuple_))")
        if let tuple = tuple_ {
            return tuple
        } else {
            if let tuple = cass_tuple_new(self.count) {
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
                if let data_type = DataType(cass_tuple_data_type(tuple)) {
                    return data_type
                }
            }
        }
        fatalError(FATAL_ERROR_MESSAGE)
    }
    // minimum requis pour satisfaire le protocole 'Collection'
    public var startIndex: Int { return 0 }
    public var endIndex: Int   { return array.count }
    public func index(after i: Int) -> Int {
        precondition(i < array.count, "Can't advance beyond endIndex")
        return i + 1
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

        case let v as String:
            rc = cass_tuple_set_string(tuple, idx,v)
        case let v as Bool:
            rc = cass_tuple_set_bool(tuple, idx, (v ? cass_true : cass_false))
        case let v as Float/*, case let v as Float32*/:
            rc = cass_tuple_set_float(tuple, idx, v)
        case let v as Double/*, let v as Float64*/:
            rc = cass_tuple_set_double(tuple, idx, v)
        case let v as Int8 /*, let v as Int*/:
            rc = cass_tuple_set_int8(tuple, idx, v)
        case let v as Int16 /*, let v as Int*/:
            rc = cass_tuple_set_int16(tuple, idx, v)
        case let v as Int32 /*, let v as Int*/:
            rc = cass_tuple_set_int32(tuple, idx, v)
        case let v as UInt32 /*, let v as Int*/:
            rc = cass_tuple_set_uint32(tuple, idx, v)
        case let v as Int64 /*, let v as Int*/:
            rc = cass_tuple_set_int64(tuple, idx, v)
        case let v as Tuple:
            let tuple = v.tuple
            rc = cass_tuple_set_tuple(tuple, idx, tuple)
        case let v as BLOB:
            rc = cass_tuple_set_bytes(tuple, idx, v, v.count)

        case let v as UUID:
            rc = cass_tuple_set_uuid(tuple, idx, v.cassUuid)
        case let v as Date:
            rc = cass_tuple_set_int64(tuple, idx, v.timestamp)
        case let v as Duration:
            rc = cass_tuple_set_duration(tuple, idx, v.months, v.days, v.nanos)
        case let v as Decimal:
            let (varint, varint_size, int32) = v.decimal
            rc = cass_tuple_set_decimal(tuple, idx, varint, varint_size, int32)
        default:
            if let collection = toCollection(value: value!) {
                defer {
                    cass_collection_free(collection)
                }
                rc = cass_tuple_set_collection(tuple, idx, collection)
            } else {
                print("*** Invalid argument: index=\(idx), type of=\(type(of:value!)), Any=\(value!)")
                rc = CASS_ERROR_LIB_INVALID_VALUE_TYPE
            }
        }
    }
    return rc
}

// autre approche possible...
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

