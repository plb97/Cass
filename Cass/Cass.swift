//
//  Cass.swift
//  Cass
//
//  Created by Philippe on 19/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

import Foundation

func allocPointer<T>(_ p: T, count: Int = 1) -> UnsafeMutableRawPointer {
    let ump = UnsafeMutablePointer<T>.allocate(capacity: count)
        ump.initialize(to: p, count: count)
    let ptr = UnsafeMutableRawPointer(ump)
    print("allocPointer<T>: T=\(T.self) ptr=\(ptr) bytes=\(count * MemoryLayout<T>.stride) alignedTo=\(MemoryLayout<T>.alignment)")
    return ptr
}
func deallocPointer<T>(_ p_: UnsafeMutableRawPointer?, as _ : T.Type, count: Int = 1) {
    if let ptr = p_ {
        print("deallocPointer<T>: T=\(T.self) ptr=\(ptr) bytes=\(count * MemoryLayout<T>.stride) alignedTo=\(MemoryLayout<T>.alignment)")
        let ump = ptr.bindMemory(to: T.self, capacity: count)
            ump.deinitialize(count: count)
            ump.deallocate(capacity: count)
    }
}
func pointee<T>(_ ptr: UnsafeMutableRawPointer, as _ : T.Type, count: Int = 1) -> T {
    print("pointee<T>: T=\(T.self) ptr=\(ptr) bytes=\(count * MemoryLayout<T>.stride) alignedTo=\(MemoryLayout<T>.alignment)")
    return ptr.bindMemory(to: T.self, capacity: count).pointee
}

public typealias Date = Foundation.Date

extension Date {
    public init(timestamp: Int64) {
        self.init(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
    }
    public var timestamp: Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    public var cass: Int64 {
        return timestamp
    }
}

struct BLOB: RandomAccessCollection, MutableCollection {
    typealias Element = UInt8
    typealias Index = Int
    var array: [Element]
    var startIndex: Int { return array.startIndex }
    var endIndex: Int { return array.endIndex }
    init(_ array: Array<UInt8>) {
        self.array = array
    }
    init(repeating: UInt8 = 0, count: Int) {
        self.array = Array(repeating: repeating, count: count)
    }
    init(ptr buf_: UnsafePointer<UInt8>? = nil, len: Int = 0) {
        if let buf = buf_, 0 < len {
            self.array = Array(UnsafeBufferPointer(start: buf, count: len))
        } else {
            self.array = Array()
        }
    }
    func index(after i: Int) -> Int {
        return array.index(after:i)
    }
    func index(before i: Int) -> Int {
        return array.index(before: i)
    }
    subscript(position: Int) -> UInt8 {
        get {
            return array[position]
        }
        set(newValue) {
            array[position] = newValue
        }
    }
    var cass: (UnsafePointer<UInt8>, size_t) { return (ptr: UnsafePointer<UInt8>(self.array), len: self.array.count) }
}

public typealias Decimal = Foundation.Decimal

extension Decimal {
    public init(ptr data: UnsafePointer<UInt8>?, length len: Int = 0, scale: Int32 = 0) {
        let buf = Array(UnsafeBufferPointer(start: data, count: len).reversed())
        let bytesPointer = UnsafeMutableRawPointer.allocate(bytes: 8, alignedTo: 8)
        defer {
            bytesPointer.deallocate(bytes: 8, alignedTo: 8)
        }
        bytesPointer.initializeMemory(as: UInt64.self, to: 0)
        bytesPointer.copyBytes(from: buf, count: len)
        let f = Int64(1 << (8*len))
        let pu = pointee(bytesPointer, as: Int64.self)
        let u = pu  > f >> 1 ? pu - f : pu
        if 0 > u {
            self.init(sign:.minus, exponent: -Int(scale), significand: Decimal(-u))
        } else {
            self.init(sign:.plus, exponent: -Int(scale), significand: Decimal(u))
        }
    }
    public var cass: (varint: UnsafePointer<UInt8>, varint_size: Int, scale: Int32) {
        let exp = Int32(self.exponent)
        let u = NSDecimalNumber(decimal: self.significand).int64Value
        let ia = Array(UnsafeBufferPointer(start: allocPointer(u).bindMemory(to: UInt8.self, capacity: 8), count: 8))
        var varint_size = 0
        for b in ia {
            varint_size += 1
            if 0 == b || 255 == b {
                break
            }
        }
        let dec = ia[0..<varint_size]
        let rdec = Array(dec.reversed())
        let varint = UnsafeRawPointer(rdec).bindMemory(to: UInt8.self, capacity: varint_size)
        let scale = -exp
        print("A revoir decimal=\(self.description) varint=\(varint) varint_size=\(varint_size) scale=\(scale)") // TODO
        return (varint, varint_size, scale)
    }
}

typealias ptr_index_error_f = (OpaquePointer?, Int, UnsafeMutablePointer<UnsafePointer<Int8>?>?, UnsafeMutablePointer<Int>?) -> CassError
typealias ptr_error_f = (OpaquePointer?, UnsafeMutablePointer<UnsafePointer<Int8>?>?, UnsafeMutablePointer<Int>?) -> CassError
typealias ptr_f = (OpaquePointer?, UnsafeMutablePointer<UnsafePointer<Int8>?>?, UnsafeMutablePointer<Int>?) -> ()
typealias ptr_f0 = (OpaquePointer?, UnsafeMutablePointer<Int>?) -> (UnsafePointer<Int8>?)
extension String {
    init?(_ function: ptr_f0, ptr ptr_: OpaquePointer?) {
        if let ptr = ptr_ {
            var name_length: Int = 0
            let name = function(ptr, &name_length)
            self.init(ptr: name, len: name_length)!
        } else {
            return nil
        }
    }
    init?(function: ptr_f, ptr ptr_: OpaquePointer?) {
        if let ptr = ptr_ {
            var name: UnsafePointer<Int8>?
            var name_length: Int = 0
            function(ptr, &name, &name_length)
            self.init(ptr: name, len: name_length)!
        } else {
            return nil
        }
    }
    init?(function: ptr_error_f, ptr ptr_: OpaquePointer?) {
        if let ptr = ptr_ {
            var name: UnsafePointer<Int8>?
            var name_length: Int = 0
            let rc = function(ptr, &name, &name_length)
            if CASS_OK == rc {
                self.init(ptr: name, len: name_length)!
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    init?(function: ptr_index_error_f, ptr ptr_: OpaquePointer?, index: Int) {
        if let ptr = ptr_ {
            var name: UnsafePointer<Int8>?
            var name_length: Int = 0
            let rc = function(ptr, index, &name, &name_length)
            if CASS_OK == rc {
                self.init(ptr: name, len: name_length)!
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    init?(ptr: UnsafePointer<Int8>? = nil, len: Int = -1) {
        if nil == ptr || 0 > len {
            return nil
        }
        let size = 0 > len ? Int(strlen(ptr)) : len + 1
        let p = UnsafeMutablePointer<Int8>.allocate(capacity: size)
        defer {
            p.deallocate(capacity: size)
        }
        p.initialize(to: 0, count:size)
        strncpy(p, ptr, size - 1) // ATTENTION : 'len' peut etre different de 'size - 1'
        self.init(validatingUTF8: p)
    }
}

public typealias UUID = Foundation.UUID

extension UUID {
    init(cass: inout CassUuid) {
        self.init(time_and_version: cass.time_and_version,clock_seq_and_node: cass.clock_seq_and_node)
    }
    public init(time_and_version: UInt64 = 0, clock_seq_and_node: UInt64 = 0) {
        var cass_uuid = CassUuid(time_and_version: time_and_version,clock_seq_and_node: clock_seq_and_node)
        let bytesPointer = UnsafeMutableRawPointer.allocate(bytes: 16, alignedTo: 1)
        defer {
            bytesPointer.deallocate(bytes: 16, alignedTo: 1)
        }
        bytesPointer.copyBytes(from: &cass_uuid, count: 16)
        let pu = bytesPointer.bindMemory(to: UInt8.self, capacity: 16)
        self.init(uuid: uuid_t(
            (pu+3).pointee,
            (pu+2).pointee,
            (pu+1).pointee,
            (pu+0).pointee,
            (pu+5).pointee,
            (pu+4).pointee,
            (pu+7).pointee,
            (pu+6).pointee,
            (pu+15).pointee,
            (pu+14).pointee,
            (pu+13).pointee,
            (pu+12).pointee,
            (pu+11).pointee,
            (pu+10).pointee,
            (pu+9).pointee,
            (pu+8).pointee)
        )
    }
    var cass: CassUuid {
        let a = [self.uuid.3,
                 self.uuid.2,
                 self.uuid.1,
                 self.uuid.0,
                 self.uuid.5,
                 self.uuid.4,
                 self.uuid.7,
                 self.uuid.6,
                 self.uuid.15,
                 self.uuid.14,
                 self.uuid.13,
                 self.uuid.12,
                 self.uuid.11,
                 self.uuid.10,
                 self.uuid.9,
                 self.uuid.8]
        let bytesPointer = UnsafeMutableRawPointer.allocate(bytes: 16, alignedTo: 8)
        defer {
            bytesPointer.deallocate(bytes: 16, alignedTo: 8)
        }
        bytesPointer.copyBytes(from: a, count: 16)
        let pu = pointee(bytesPointer, as: CassUuid.self)
        return pu
    }
    public var time_and_version: UInt64 {
        return self.cass.time_and_version
    }
    public var clock_seq_and_node: UInt64 {
        return self.cass.clock_seq_and_node
    }
    public var timestamp: UInt64 { // millisecondes
        return cass_uuid_timestamp(self.cass)
    }
    public var version: UInt8 {
        return cass_uuid_version(self.cass)
    }
    public var string: String {
        let len = Int(CASS_UUID_STRING_LENGTH)
        let p = UnsafeMutablePointer<Int8>.allocate(capacity: len)
        defer {
            p.deallocate(capacity: len)
        }
        p.initialize(to: 0, count:len)
        cass_uuid_string(self.cass,p)
        return String(validatingUTF8: p)!
    }
}

public struct Inet: CustomStringConvertible, Hashable {
    let cass: CassInet
    init(cass: CassInet) {
        self.cass = cass
    }
    init(v4: Array<UInt8>) {
        self.init(cass: cass_inet_init_v4(v4))
    }
    init(v6: Array<UInt8>) {
        self.init(cass: cass_inet_init_v6(v6))
    }
    init(fromString str: String) {
        var output = CassInet()
        let rc = cass_inet_from_string(str, &output)
        if CASS_OK == rc {
            self.init(cass: output)
        } else {
            fatalError(CASS_OK.description)
        }
    }
    public var description: String {
        let len = Int(CASS_INET_STRING_LENGTH+1) // = 47
        let str = UnsafeMutablePointer<Int8>.allocate(capacity: len)
        defer {
            str.deinitialize(count: len)
            str.deallocate(capacity: len)
        }
        str.initialize(to: 0, count: len)
        cass_inet_string(cass,str)
        return String(validatingUTF8: str)!
    }
    public var hashValue: Int {
        return description.hashValue
    }

    public static func ==(lhs: Inet, rhs: Inet) -> Bool {
        return lhs.description == rhs.description
    }

}

public struct Duration {
    public var months: Int32
    public var days: Int32
    public var nanos: Int64
    public init(months: Int32, days: Int32, nanos: Int64) {
        self.months = months
        self.days = days
        self.nanos = nanos
    }
    var cass: (months: Int32, days: Int32, nanos: Int64) { return (months, days, nanos) }
}

extension Int8 {
    var cass: cass_int8_t { return self }
}
extension Int16 {
    var cass: cass_int16_t { return self }
}
extension Int32 {
    var cass: cass_int32_t { return self }
}
extension Int {
    var cass: cass_int32_t { return Int32(self) }
}
extension UInt32 {
    var cass: cass_uint32_t { return self }
}
extension UInt {
    var cass: cass_uint32_t { return UInt32(self) }
}
extension Int64 {
    var cass: cass_int64_t { return self }
}
extension Float {
    var cass: cass_float_t { return self }
}
extension Double {
    var cass: cass_double_t { return self }
}
extension Bool {
    var cass: cass_bool_t { return self ? cass_true : cass_false }
}
extension String {
    var cass: (UnsafePointer<Int8>, size_t) { return (ptr: UnsafePointer<Int8>(self), len: self.count) }
}
extension Set {
    var cass: OpaquePointer { if let collection = toCollection(cass: self) { return collection } else { fatalError(FATAL_ERROR_MESSAGE)} }
}
extension Array {
    var cass: OpaquePointer { if let collection = toCollection(cass: self) { return collection } else { fatalError(FATAL_ERROR_MESSAGE)} }
}
extension Dictionary {
    var cass: OpaquePointer { if let collection = toCollection(cass: self) { return collection } else { fatalError(FATAL_ERROR_MESSAGE)} }
}

fileprivate func toCollection(cass value_: Any?) -> OpaquePointer? {
    if let value = value_ {
        switch value {
        case let vs as Set<String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            for v in vs {
                cass_collection_append_string(collection, v)
            }
            return collection
        case let vs as Set<Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            for v in vs {
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            return collection
        case let vs as Set<Float>/*, let vs as Set<Float>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            for v in vs {
                cass_collection_append_float(collection, v)
            }
            return collection
        case let vs as Set<Double>/*, let vs as Set<Double>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            for v in vs {
                cass_collection_append_double(collection, v)
            }
            return collection
        case let vs as Set<Int8> /*, let vs as Set<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            for v in vs {
                cass_collection_append_int8(collection, v)
            }
            return collection
        case let vs as Set<Int16> /*, let vs as Set<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            for v in vs {
                cass_collection_append_int16(collection, v)
            }
            return collection
        case let vs as Set<Int32> /*, let vs as Set<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            for v in vs {
                cass_collection_append_int32(collection, v)
            }
            return collection
        case let vs as Set<Int64> /*, let vs as Set<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            for v in vs {
                cass_collection_append_int64(collection, v)
            }
            return collection
        case let vs as Set<UInt32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            for v in vs {
                cass_collection_append_uint32(collection, v)
            }
            return collection
        case let vs as Set<UUID>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            for v in vs {
                cass_collection_append_uuid(collection, v.cass)
            }
            return collection
        case let vs as Set<Inet>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            for v in vs {
                cass_collection_append_inet(collection, v.cass)
            }
            return collection
        case let vs as Set<Tuple>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            for v in vs {
                cass_collection_append_tuple(collection, v.cass)
            }
            return collection
        case let vs as Set<UserType>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            for v in vs {
                cass_collection_append_user_type(collection, v.cass)
            }
            return collection

        case let vs as Array<String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            for v in vs {
                cass_collection_append_string(collection, v)
            }
            return collection
        case let vs as Array<Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            for v in vs {
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            return collection
        case let vs as Array<Float>/*, let v as Array<Float>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            for v in vs {
                cass_collection_append_float(collection, v)
            }
            return collection
        case let vs as Array<Double>/*, let vs as Array<Double>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            for v in vs {
                cass_collection_append_double(collection, v)
            }
            return collection
        case let vs as Array<Int8> /*, let vs as Array<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            for v in vs {
                cass_collection_append_int8(collection, v)
            }
            return collection
        case let vs as Array<Int16> /*, let vs as Array<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            for v in vs {
                cass_collection_append_int16(collection, v)
            }
            return collection
        case let vs as Array<Int32> /*, let vs as Array<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            for v in vs {
                cass_collection_append_int32(collection, v)
            }
            return collection
        case let vs as Array<Int64> /*, let vs as Array<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            for v in vs {
                cass_collection_append_int64(collection, v)
            }
            return collection
        case let vs as Array<UInt32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            for v in vs {
                cass_collection_append_uint32(collection, v)
            }
            return collection
        case let vs as Array<UUID>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            for v in vs {
                cass_collection_append_uuid(collection, v.cass)
            }
            return collection
        case let vs as Array<Inet>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            for v in vs {
                cass_collection_append_inet(collection, v.cass)
            }
            return collection
        case let vs as Array<Tuple>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            for v in vs {
                cass_collection_append_tuple(collection, v.cass)
            }
            return collection
        case let vs as Array<UserType>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            for v in vs {
                cass_collection_append_user_type(collection, v.cass)
            }
            return collection

        case let vs as Dictionary<String, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_string(collection, v)
            }
            return collection
        case let vs as Dictionary<String, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            return collection
        case let vs as Dictionary<String, Float>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_float(collection, v)
            }
            return collection
        case let vs as Dictionary<String, Double>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_double(collection, v)
            }
            return collection
        case let vs as Dictionary<String, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int8(collection, v)
            }
            return collection
        case let vs as Dictionary<String, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int16(collection, v)
            }
            return collection
        case let vs as Dictionary<String, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int32(collection, v)
            }
            return collection
        case let vs as Dictionary<String, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int64(collection, v)
            }
            return collection
        case let vs as Dictionary<String, UInt32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_uint32(collection, v)
            }
            return collection
        case let vs as Dictionary<String, UUID>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_uuid(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<String, Inet>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_inet(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<String, Tuple>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_tuple(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<String, UserType>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_user_type(collection, v.cass)
            }
            return collection

        case let vs as Dictionary<Bool, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_string(collection, v)
            }
            return collection
        case let vs as Dictionary<Bool, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            return collection
        case let vs as Dictionary<Bool, Float>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_float(collection, v)
            }
            return collection
        case let vs as Dictionary<Bool, Double>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_double(collection, v)
            }
            return collection
        case let vs as Dictionary<Bool, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int8(collection, v)
            }
            return collection
        case let vs as Dictionary<Bool, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int16(collection, v)
            }
            return collection
        case let vs as Dictionary<Bool, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int32(collection, v)
            }
            return collection
        case let vs as Dictionary<Bool, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int64(collection, v)
            }
            return collection
        case let vs as Dictionary<Bool, UInt32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_uint32(collection, v)
            }
            return collection
        case let vs as Dictionary<Bool, UUID>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_uuid(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Bool, Inet>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_inet(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Bool, Tuple>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_tuple(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Bool, UserType>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_user_type(collection, v.cass)
            }
            return collection

        case let vs as Dictionary<Float, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_string(collection, v)
            }
            return collection
        case let vs as Dictionary<Float, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            return collection
        case let vs as Dictionary<Float, Float>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_float(collection, v)
            }
            return collection
        case let vs as Dictionary<Float, Double>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_double(collection, v)
            }
            return collection
        case let vs as Dictionary<Float, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int8(collection, v)
            }
            return collection
        case let vs as Dictionary<Float, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int16(collection, v)
            }
            return collection
        case let vs as Dictionary<Float, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int32(collection, v)
            }
            return collection
        case let vs as Dictionary<Float, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int64(collection, v)
            }
            return collection
        case let vs as Dictionary<Float, UInt32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_uint32(collection, v)
            }
            return collection
        case let vs as Dictionary<Float, UUID>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_uuid(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Float, Inet>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_inet(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Float, Tuple>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_tuple(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Float, UserType>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_user_type(collection, v.cass)
            }
            return collection

        case let vs as Dictionary<Double, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_string(collection, v)
            }
            return collection
        case let vs as Dictionary<Double, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            return collection
        case let vs as Dictionary<Double, Float>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_float(collection, v)
            }
            return collection
        case let vs as Dictionary<Double, Double>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_double(collection, v)
            }
            return collection
        case let vs as Dictionary<Double, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int8(collection, v)
            }
            return collection
        case let vs as Dictionary<Double, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int16(collection, v)
            }
            return collection
        case let vs as Dictionary<Double, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int32(collection, v)
            }
            return collection
        case let vs as Dictionary<Double, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int64(collection, v)
            }
            return collection
        case let vs as Dictionary<Double, UInt32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_uint32(collection, v)
            }
            return collection
        case let vs as Dictionary<Double, UUID>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_uuid(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Double, Inet>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_inet(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Double, Tuple>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_tuple(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Double, UserType>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_user_type(collection, v.cass)
            }
            return collection

        case let vs as Dictionary<Int8, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_string(collection, v)
            }
            return collection
        case let vs as Dictionary<Int8, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            return collection
        case let vs as Dictionary<Int8, Float>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_float(collection, v)
            }
            return collection
        case let vs as Dictionary<Int8, Double>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_double(collection, v)
            }
            return collection
        case let vs as Dictionary<Int8, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int8(collection, v)
            }
            return collection
        case let vs as Dictionary<Int8, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int16(collection, v)
            }
            return collection
        case let vs as Dictionary<Int8, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int32(collection, v)
            }
            return collection
        case let vs as Dictionary<Int8, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int64(collection, v)
            }
            return collection
        case let vs as Dictionary<Int8, UInt32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_uint32(collection, v)
            }
            return collection
        case let vs as Dictionary<Int8, UUID>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_uuid(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Int8, Inet>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_inet(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Int8, Tuple>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_tuple(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Int8, UserType>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_user_type(collection, v.cass)
            }
            return collection

        case let vs as Dictionary<Int16, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_string(collection, v)
            }
            return collection
        case let vs as Dictionary<Int16, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            return collection
        case let vs as Dictionary<Int16, Float>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_float(collection, v)
            }
            return collection
        case let vs as Dictionary<Int16, Double>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_double(collection, v)
            }
            return collection
        case let vs as Dictionary<Int16, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int8(collection, v)
            }
            return collection
        case let vs as Dictionary<Int16, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int16(collection, v)
            }
            return collection
        case let vs as Dictionary<Int16, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int32(collection, v)
            }
            return collection
        case let vs as Dictionary<Int16, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int64(collection, v)
            }
            return collection
        case let vs as Dictionary<Int32, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_string(collection, v)
            }
            return collection
        case let vs as Dictionary<Int16, UInt32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_uint32(collection, v)
            }
            return collection
        case let vs as Dictionary<Int16, UUID>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_uuid(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Int16, Inet>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_inet(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Int16, Tuple>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_tuple(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Int16, UserType>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_user_type(collection, v.cass)
            }
            return collection

        case let vs as Dictionary<Int32, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            return collection
        case let vs as Dictionary<Int32, Float>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_float(collection, v)
            }
            return collection
        case let vs as Dictionary<Int32, Double>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_double(collection, v)
            }
            return collection
        case let vs as Dictionary<Int32, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int8(collection, v)
            }
            return collection
        case let vs as Dictionary<Int32, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int16(collection, v)
            }
            return collection
        case let vs as Dictionary<Int32, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int32(collection, v)
            }
            return collection
        case let vs as Dictionary<Int32, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int64(collection, v)
            }
            return collection
        case let vs as Dictionary<Int32, UInt32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_uint32(collection, v)
            }
            return collection
        case let vs as Dictionary<Int32, UUID>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_uuid(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Int32, Inet>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_inet(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Int32, Tuple>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_tuple(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Int32, UserType>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_user_type(collection, v.cass)
            }
            return collection

        case let vs as Dictionary<Int64, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_string(collection, v)
            }
            return collection
        case let vs as Dictionary<Int64, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            return collection
        case let vs as Dictionary<Int64, Float>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_float(collection, v)
            }
            return collection
        case let vs as Dictionary<Int64, Double>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_double(collection, v)
            }
            return collection
        case let vs as Dictionary<Int64, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int8(collection, v)
            }
            return collection
        case let vs as Dictionary<Int64, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int16(collection, v)
            }
            return collection
        case let vs as Dictionary<Int64, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int32(collection, v)
            }
            return collection
        case let vs as Dictionary<Int64, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int64(collection, v)
            }
            return collection
        case let vs as Dictionary<Int64, UInt32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_uint32(collection, v)
            }
            return collection
        case let vs as Dictionary<Int64, UUID>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_uuid(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Int64, Inet>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_inet(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Int64, Tuple>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_tuple(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<Int64, UserType>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_user_type(collection, v.cass)
            }
            return collection

        case let vs as Dictionary<UInt32, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_uint32(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            return collection
        case let vs as Dictionary<UInt32, Float>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_uint32(collection, k)
                cass_collection_append_float(collection, v)
            }
            return collection
        case let vs as Dictionary<UInt32, Double>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_uint32(collection, k)
                cass_collection_append_double(collection, v)
            }
            return collection
        case let vs as Dictionary<UInt32, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_uint32(collection, k)
                cass_collection_append_int8(collection, v)
            }
            return collection
        case let vs as Dictionary<UInt32, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_uint32(collection, k)
                cass_collection_append_int16(collection, v)
            }
            return collection
        case let vs as Dictionary<UInt32, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_uint32(collection, k)
                cass_collection_append_int32(collection, v)
            }
            return collection
        case let vs as Dictionary<UInt32, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_uint32(collection, k)
                cass_collection_append_int64(collection, v)
            }
            return collection
        case let vs as Dictionary<UInt32, UInt32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_uint32(collection, k)
                cass_collection_append_uint32(collection, v)
            }
            return collection
        case let vs as Dictionary<UInt32, UUID>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_uint32(collection, k)
                cass_collection_append_uuid(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<UInt32, Inet>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_uint32(collection, k)
                cass_collection_append_inet(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<UInt32, Tuple>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_uint32(collection, k)
                cass_collection_append_tuple(collection, v.cass)
            }
            return collection
        case let vs as Dictionary<UInt32, UserType>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            for (k, v) in vs {
                cass_collection_append_uint32(collection, k)
                cass_collection_append_user_type(collection, v.cass)
            }
            return collection

        default:
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    return nil
}

