//
//  Cass.swift
//  Cass
//
//  Created by Philippe on 19/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

import Foundation

// http://docs.datastax.com/en/developer/cpp-driver/2.7/

func utf8_string(text: UnsafePointer<Int8>?, len: Int) -> String? {
    if nil == text || 0 > len {
        return nil
    }
    let p = UnsafeMutablePointer<Int8>.allocate(capacity: len+1)
    defer {
        p.deallocate(capacity: len+1)
    }
    p.initialize(to: 0, count:len+1)
    strncpy(p, text, len)
    return String(validatingUTF8: p)
}
/*
typealias to_string_f = (OpaquePointer?, UnsafeMutablePointer<UnsafePointer<Int8>?>?, UnsafeMutablePointer<Int>?) -> ()
func to_string(_ data: OpaquePointer?,_ fn: to_string_f) -> String? {
    var text: UnsafePointer<Int8>?
    var len: Int = 0
    fn(data, &text, &len)
    return utf8_string(text: text, len: len)
}
*/
/*
func futureMessage(_ future: OpaquePointer) -> String? {
    let rc = cass_future_error_code(future)
    if (CASS_OK != rc) {
        defer {
            cass_future_free(future)
        }
        if let msg = error_string(future) {
            return msg
        } else {
            return message(rc,"Execution error ")
        }
    }
    return nil
}
*/
func uuid_(cass_uuid: inout CassUuid) -> UUID {
    let bytesPointer = UnsafeMutableRawPointer.allocate(bytes: 16, alignedTo: 1)
    defer {
        bytesPointer.deallocate(bytes: 16, alignedTo: 1)
    }
    bytesPointer.copyBytes(from: &cass_uuid, count: 16)
    let pu = bytesPointer.bindMemory(to: UInt8.self, capacity: 16)
    let u = UUID(uuid: uuid_t(
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
    return u
}
func uuid_(uuid: UUID) -> CassUuid {
    let a = [uuid.uuid.3,
             uuid.uuid.2,
             uuid.uuid.1,
             uuid.uuid.0,
             uuid.uuid.5,
             uuid.uuid.4,
             uuid.uuid.7,
             uuid.uuid.6,
             uuid.uuid.15,
             uuid.uuid.14,
             uuid.uuid.13,
             uuid.uuid.12,
             uuid.uuid.11,
             uuid.uuid.10,
             uuid.uuid.9,
             uuid.uuid.8]
    let bytesPointer = UnsafeMutableRawPointer.allocate(bytes: 16, alignedTo: 8)
    defer {
        bytesPointer.deallocate(bytes: 16, alignedTo: 8)
    }
    bytesPointer.copyBytes(from: a, count: 16)
    let pu = bytesPointer.bindMemory(to: CassUuid.self, capacity: 1)
    return pu.pointee
}
fileprivate func string(uuid: uuid_t, upper: Bool = false) -> String {
    let fmt = upper
        ? "%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X"
        : "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x"
    return String(format: fmt,
                  uuid.0,
                  uuid.1,
                  uuid.2,
                  uuid.3,

                  uuid.4,
                  uuid.5,

                  uuid.6,
                  uuid.7,

                  uuid.8,
                  uuid.9,

                  uuid.10,
                  uuid.11,
                  uuid.12,
                  uuid.13,
                  uuid.14,
                  uuid.15)
}

/*
 CASS_EXPORT CassFuture* cass_session_connect(CassSession* session, const CassCluster* cluster);
 CASS_EXPORT CassFuture* cass_session_connect_keyspace(CassSession* session, const CassCluster* cluster, const char* keyspace);
 CASS_EXPORT CassFuture* cass_session_close(CassSession* session);
 CASS_EXPORT CassFuture* cass_session_prepare(CassSession* session, const char* query);
 CASS_EXPORT CassFuture* cass_session_execute(CassSession* session, const CassStatement* statement);
 CASS_EXPORT CassFuture* cass_session_execute_batch(CassSession* session, const CassBatch* batch);
 */
/*
 null
 int8
 int16
 int32
 uint32
 int64
 float
 double
 bool
 string
 bytes  (bytes value, int size)
 uuid   (CassUuid)
 inet   (CassInet)
 decimal    (bytes varint, int size, int32 scale)
 duration (int32 months, int32 days, int64 nanos)
 collection (list, set, map)    (CassCollection)
 tuple  (CassTuple)
 user_type  (CassUserType)

 custom?    (string class_name, bytes value, size int)

 */
/*
 cass_statement_bind_null(CassStatement* statement          => nil
 cass_statement_bind_int8(CassStatement* statement          => Int8
 cass_statement_bind_int16(CassStatement* statement         => Int16
 cass_statement_bind_int32(CassStatement* statement         => Int32
 cass_statement_bind_uint32(CassStatement* statement        => UInt32
 cass_statement_bind_int64(CassStatement* statement         => Int64, Foundation.Date
 cass_statement_bind_float(CassStatement* statement         => Float
 cass_statement_bind_double(CassStatement* statement        => Double
 cass_statement_bind_bool(CassStatement* statement          => Bool
 cass_statement_bind_string(CassStatement* statement        => String
 cass_statement_bind_bytes(CassStatement* statement         => Array<UInt8>
 cass_statement_bind_custom(CassStatement* statement
 cass_statement_bind_uuid(CassStatement* statement          => Foundation.UUID
 cass_statement_bind_inet(CassStatement* statement
 cass_statement_bind_decimal(CassStatement* statement          => Foundation.Decimal?
 cass_statement_bind_duration(CassStatement* statement        => Foundation.?
 cass_statement_bind_collection(CassStatement* statement    => Set, Array, Dictionary
 cass_statement_bind_tuple(CassStatement* statement             => Foundation.?
 */

func timestamp(date: Date) -> Int64 {
    return Int64(date.timeIntervalSince1970 * 1000)
}
func date(timestamp: Int64) -> Date {
    return Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
}

func bind(_ statement: OpaquePointer, lst: [Any?]) {
    for (idx,value) in lst.enumerated() {
        if let v = value {
            let t = type(of:v)
            print("index=",idx,"type of=",t,"->", type(of:t))
        }
        switch value {
        case nil:
            print(idx,"<nil>")
            cass_statement_bind_null(statement, idx)

        case let v as String:
            print(idx,"String",v)
            cass_statement_bind_string(statement, idx,v)
        case let v as Bool:
            print(idx,"Bool",v)
            cass_statement_bind_bool(statement, idx, (v ? cass_true : cass_false))
        case let v as Float32/*, case let v as Float*/:
            print(idx,"Float32 (float)",v)
            cass_statement_bind_float(statement, idx, v)
        case let v as Float64/*, let v as Double*/:
            print(idx,"Float64 (double)",v)
            cass_statement_bind_double(statement, idx, v)
        case let v as Int8 /*, let v as Int*/:
            print(idx,"Int8",v)
            cass_statement_bind_int8(statement, idx, v)
        case let v as Int16 /*, let v as Int*/:
            print(idx,"Int16",v)
            cass_statement_bind_int16(statement, idx, v)
        case let v as Int32 /*, let v as Int*/:
            print(idx,"Int32",v)
            cass_statement_bind_int32(statement, idx, v)
        case let v as Int64 /*, let v as Int*/:
            print(idx,"Int64",v)
            cass_statement_bind_int64(statement, idx, v)
        case let v as Array<UInt8>:
            print(idx,"Array<UInt8>",v)
            cass_statement_bind_bytes(statement, idx, v, v.count)
        // Foundation types
        case let v as UUID:
            print(idx,"UUID",v)
            cass_statement_bind_uuid(statement, idx, uuid_(uuid:v))
        case let v as Date:
            print(idx,"Date",v)
            cass_statement_bind_int64(statement, idx, timestamp(date: v))
        case let v as Duration:
            cass_statement_bind_duration(statement, idx, v.months, v.days, v.nanos)
//        case let v as Decimal:
//             print(idx,"Decimal",v)
//             let exp = Int32(v.exponent)
//             let u = NSDecimalNumber(decimal: v.significand).int64Value
//             print(">>> u=\(u) exp=\(exp) \(String(format:"%02X",u))")
//             var ptr = UnsafeMutableRawPointer.allocate(bytes: 8, alignedTo: 8)
//             defer {
//                ptr.deallocate(bytes: 8, alignedTo: 8)
//             }
//             ptr.storeBytes(of: u, as: Int64.self)
//             let ia = Array(UnsafeBufferPointer(start: ptr.bindMemory(to: UInt8.self, capacity: 8), count: 8))
//             var n = 0
//             for b in ia {
//                n += 1
//                if 0 == b || 255 == b {
//                    break
//                }
//             }
//             let dec = ia[0..<n]
//             print(">>> u=\(u) exp=\(exp) ptr=\(ptr) n=\(n) dec=\(dec) \(type(of: dec))")
//             let rdec = Array(dec.reversed())
//             print(">>> u=\(u) exp=\(exp) ptr=\(ptr) dec=\(rdec) \(type(of: rdec))")
//             let val = UnsafeRawPointer(rdec).bindMemory(to: UInt8.self, capacity: n)
//             cass_statement_bind_decimal(statement, idx, val, n, -exp)
        case let vs as Set<String>:
            print(idx,"Set<String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Set<Bool>:
            print(idx,"Set<Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Set<Float32>/*, let vs as Set<Float>*/:
            print(idx,"Set<Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Set<Float64>/*, let vs as Set<Double>*/:
            print(idx,"Set<Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Set<Int8> /*, let vs as Set<Int>*/:
            print(idx,"Set<Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Set<Int16> /*, let vs as Set<Int>*/:
            print(idx,"Set<Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Set<Int32> /*, let vs as Set<Int>*/:
            print(idx,"Set<Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Set<Int64> /*, let vs as Set<Int>*/:
            print(idx,"Set<Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)

        case let vs as Array<String>:
            print(idx,"Array<String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Array<Bool>:
            print(idx,"Array<Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Array<Float32>/*, let v as Array<Float>*/:
            print(idx,"Array<Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Array<Float64>/*, let vs as Array<Double>*/:
            print(idx,"Array<Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Array<Int8> /*, let vs as Array<Int>*/:
            print(idx,"Array<Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Array<Int16> /*, let vs as Array<Int>*/:
            print(idx,"Array<Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Array<Int32> /*, let vs as Array<Int>*/:
            print(idx,"Array<Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Array<Int64> /*, let vs as Array<Int>*/:
            print(idx,"Array<Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)

        case let vs as Dictionary<String, String>:
            print(idx,"Dictionary<String, String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<String, Bool>:
            print(idx,"Dictionary<String, Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<String, Float32>:
            print(idx,"Dictionary<String, Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<String, Float64>:
            print(idx,"Dictionary<String, Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<String, Int8>:
            print(idx,"Dictionary<String, Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<String, Int16>:
            print(idx,"Dictionary<String, Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<String, Int32>:
            print(idx,"Dictionary<String, Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<String, Int64>:
            print(idx,"Dictionary<String, Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Bool, String>:
            print(idx,"Dictionary<Bool, String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Bool, Bool>:
            print(idx,"Dictionary<Bool, Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Bool, Float32>:
            print(idx,"Dictionary<Bool, Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Bool, Float64>:
            print(idx,"Dictionary<Bool, Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Bool, Int8>:
            print(idx,"Dictionary<Bool, Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Bool, Int16>:
            print(idx,"Dictionary<Bool, Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Bool, Int32>:
            print(idx,"Dictionary<Bool, Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Bool, Int64>:
            print(idx,"Dictionary<Bool, Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float32, String>:
            print(idx,"Dictionary<Float32, String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float32, Bool>:
            print(idx,"Dictionary<Float32, Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float32, Float32>:
            print(idx,"Dictionary<Float32, Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float32, Float64>:
            print(idx,"Dictionary<Float32, Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float32, Int8>:
            print(idx,"Dictionary<Float32, Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float32, Int16>:
            print(idx,"Dictionary<Float32, Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float32, Int32>:
            print(idx,"Dictionary<Float32, Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float32, Int64>:
            print(idx,"Dictionary<Float32, Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float64, String>:
            print(idx,"Dictionary<Float64, String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float64, Bool>:
            print(idx,"Dictionary<Float64, Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float64, Float32>:
            print(idx,"Dictionary<Float64, Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float64, Float64>:
            print(idx,"Dictionary<Float64, Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float64, Int8>:
            print(idx,"Dictionary<Float64, Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float64, Int16>:
            print(idx,"Dictionary<Float64, Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float64, Int32>:
            print(idx,"Dictionary<Float64, Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float64, Int64>:
            print(idx,"Dictionary<Float64, Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int8, String>:
            print(idx,"Dictionary<Int8, String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int8, Bool>:
            print(idx,"Dictionary<Int8, Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int8, Float32>:
            print(idx,"Dictionary<Int8, Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int8, Float64>:
            print(idx,"Dictionary<Int8, Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int8, Int8>:
            print(idx,"Dictionary<Int8, Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int8, Int16>:
            print(idx,"Dictionary<Int8, Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int8, Int32>:
            print(idx,"Dictionary<Int8, Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int8, Int64>:
            print(idx,"Dictionary<Int8, Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int16, String>:
            print(idx,"Dictionary<Int16, String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int16, Bool>:
            print(idx,"Dictionary<Int16, Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int16, Float32>:
            print(idx,"Dictionary<Int16, Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int16, Float64>:
            print(idx,"Dictionary<Int16, Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int16, Int8>:
            print(idx,"Dictionary<Int16, Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int16, Int16>:
            print(idx,"Dictionary<Int16, Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int16, Int32>:
            print(idx,"Dictionary<Int16, Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int16, Int64>:
            print(idx,"Dictionary<Int16, Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int32, String>:
            print(idx,"Dictionary<Int32, String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int32, Bool>:
            print(idx,"Dictionary<Int32, Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int32, Float32>:
            print(idx,"Dictionary<Int32, Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int32, Float64>:
            print(idx,"Dictionary<Int32, Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int32, Int8>:
            print(idx,"Dictionary<Int32, Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int32, Int16>:
            print(idx,"Dictionary<Int32, Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int32, Int32>:
            print(idx,"Dictionary<Int32, Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int32, Int64>:
            print(idx,"Dictionary<Int32, Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int64, String>:
            print(idx,"Dictionary<Int64, String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int64, Bool>:
            print(idx,"Dictionary<Int64, Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int64, Float32>:
            print(idx,"Dictionary<Int64, Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int64, Float64>:
            print(idx,"Dictionary<Int64, Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int64, Int8>:
            print(idx,"Dictionary<Int64, Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int64, Int16>:
            print(idx,"Dictionary<Int64, Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int64, Int32>:
            print(idx,"Dictionary<Int64, Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int64, Int64>:
            print(idx,"Dictionary<Int64, Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection(statement, idx, collection)

        default:
            print("*** index=\(idx), type of=\(type(of:value!)), Any=\(value!)")
            fatalError("Invalid argument: index=\(idx), type of=\(type(of:value!)), Any=\(value!)")
        }
    }
}
func bind(_ statement: OpaquePointer, map: [String: Any?]) {
    /*print("string",type(of:String.self))
     print("int",type(of:Int.self))
     let dico = [AnyHashable : Any?]()
     print("dico",dico)*/
    for (nam, value) in map {
        let f = {(_ value: Any?) -> () in
            if let v = value {
                let t = type(of:v)
                print("name=",nam," type of=",t,"->", type(of:t))
            }
        }
        f(value)
        switch value {
        case nil:
            print(nam,"<nil>")
            cass_statement_bind_null_by_name(statement, nam)

        case let v as String:
            print(nam,"String",v)
            cass_statement_bind_string_by_name(statement, nam,v)
        case let v as Bool:
            print(nam,"Bool",v)
            cass_statement_bind_bool_by_name(statement, nam, (v ? cass_true : cass_false))
        case let v as Float32/*, let v as Float*/:
            print(nam,"Float32 (float)",v)
            cass_statement_bind_float_by_name(statement, nam, v)
        case let v as Float64/*, let v as Double*/:
            print(nam,"Float64 (double)",v)
            cass_statement_bind_double_by_name(statement, nam, v)
        case let v as Int8 /*, let v as Int*/:
            print(nam,"Int8",v)
            cass_statement_bind_int8_by_name(statement, nam, v)
        case let v as Int16 /*, let v as Int*/:
            print(nam,"Int16",v)
            cass_statement_bind_int16_by_name(statement, nam, v)
        case let v as Int32 /*, let v as Int*/:
            print(nam,"Int32",v)
            cass_statement_bind_int32_by_name(statement, nam, v)
        case let v as Int64 /*, let v as Int*/:
            print(nam,"Int64",v)
            cass_statement_bind_int64_by_name(statement, nam, v)
        case let v as Array<UInt8>:
            print(nam,"Array<UInt8>",v)
            cass_statement_bind_bytes_by_name(statement, nam, v, v.count)
        // Foundation
        case let v as UUID:
            print(nam,"uuid_t",v)
            cass_statement_bind_uuid_by_name(statement, nam, uuid_(uuid:v))
        case let v as Date:
            print(nam,"Date",v)
            cass_statement_bind_int64_by_name(statement, nam, timestamp(date: v))
        case let v as Duration:
            print(nam,"Duration",v)
            cass_statement_bind_duration_by_name(statement, nam, v.months, v.days, v.nanos)
//        case let v as Decimal:
//             print(nam,"Decimal",v)
//             let exp = Int32(v.exponent)
//             let u = NSDecimalNumber(decimal: v.significand).int64Value
//             print(">>> u=\(u) exp=\(exp) \(String(format:"%02X",u))")
//             var ptr = UnsafeMutableRawPointer.allocate(bytes: 8, alignedTo: 8)
//             defer {
//                ptr.deallocate(bytes: 8, alignedTo: 8)
//             }
//             ptr.storeBytes(of: u, as: Int64.self)
//             let ia = Array(UnsafeBufferPointer(start: ptr.bindMemory(to: UInt8.self, capacity: 8), count: 8))
//             var n = 0
//             for b in ia {
//                n += 1
//                if 0 == b || 255 == b {
//                    break
//                }
//             }
//             let dec = ia[0..<n]
//             print(">>> u=\(u) exp=\(exp) ptr=\(ptr) n=\(n) dec=\(dec) \(type(of: dec))")
//             let rdec = Array(dec.reversed())
//             print(">>> u=\(u) exp=\(exp) ptr=\(ptr) dec=\(rdec) \(type(of: rdec))")
//             let val = UnsafeRawPointer(rdec).bindMemory(to: UInt8.self, capacity: n)
//             cass_statement_bind_decimal_by_name(statement, nam, val, n, -exp)
        case let vs as Set<String>:
            print(nam,"Set<String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Set<Bool>:
            print(nam,"Set<Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Set<Float32>/*, let vs as Set<Float>*/:
            print(nam,"Set<Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Set<Float64>/*, let vs as Set<Double>*/:
            print(nam,"Set<Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Set<Int8> /*, let vs as Set<Int>*/:
            print(nam,"Set<Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Set<Int16> /*, let vs as Set<Int>*/:
            print(nam,"Set<Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Set<Int32> /*, let vs as Set<Int>*/:
            print(nam,"Set<Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Set<Int64> /*, let vs as Set<Int>*/:
            print(nam,"Set<Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)

        case let vs as Array<String>:
            print(nam,"Array<String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Array<Bool>:
            print(nam,"Array<Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Array<Float32>/*, let vs as Array<Float>*/:
            print(nam,"Array<Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Array<Float64>/*, let vs as Array<Double>*/:
            print(nam,"Array<Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Array<Int8> /*, let vs as Array<Int>*/:
            print(nam,"Array<Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Array<Int16> /*, let vs as Array<Int>*/:
            print(nam,"Array<Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Array<Int32> /*, let vs as Array<Int>*/:
            print(nam,"Array<Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Array<Int64> /*, let vs as Array<Int>*/:
            print(nam,"Array<Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)

        case let vs as Dictionary<String, String>:
            print(nam,"Dictionary<String, String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<String, Bool>:
            print(nam,"Dictionary<String, Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<String, Float32>:
            print(nam,"Dictionary<String, Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<String, Float64>:
            print(nam,"Dictionary<String, Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<String, Int8>:
            print(nam,"Dictionary<String, Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<String, Int16>:
            print(nam,"Dictionary<String, Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<String, Int32>:
            print(nam,"Dictionary<String, Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<String, Int64>:
            print(nam,"Dictionary<String, Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Bool, String>:
            print(nam,"Dictionary<Bool, String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Bool, Bool>:
            print(nam,"Dictionary<Bool, Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Bool, Float32>:
            print(nam,"Dictionary<Bool, Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Bool, Float64>:
            print(nam,"Dictionary<Bool, Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Bool, Int8>:
            print(nam,"Dictionary<Bool, Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Bool, Int16>:
            print(nam,"Dictionary<Bool, Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Bool, Int32>:
            print(nam,"Dictionary<Bool, Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Bool, Int64>:
            print(nam,"Dictionary<Bool, Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float32, String>:
            print(nam,"Dictionary<Float32, String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float32, Bool>:
            print(nam,"Dictionary<Float32, Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float32, Float32>:
            print(nam,"Dictionary<Float32, Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float32, Float64>:
            print(nam,"Dictionary<Float32, Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float32, Int8>:
            print(nam,"Dictionary<Float32, Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float32, Int16>:
            print(nam,"Dictionary<Float32, Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float32, Int32>:
            print(nam,"Dictionary<Float32, Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float32, Int64>:
            print(nam,"Dictionary<Float32, Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float64, String>:
            print(nam,"Dictionary<Float64, String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float64, Bool>:
            print(nam,"Dictionary<Float64, Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float64, Float32>:
            print(nam,"Dictionary<Float64, Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float64, Float64>:
            print(nam,"Dictionary<Float64, Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float64, Int8>:
            print(nam,"Dictionary<Float64, Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float64, Int16>:
            print(nam,"Dictionary<Float64, Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float64, Int32>:
            print(nam,"Dictionary<Float64, Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float64, Int64>:
            print(nam,"Dictionary<Float64, Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int8, String>:
            print(nam,"Dictionary<Int8, String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int8, Bool>:
            print(nam,"Dictionary<Int8, Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int8, Float32>:
            print(nam,"Dictionary<Int8, Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int8, Float64>:
            print(nam,"Dictionary<Int8, Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int8, Int8>:
            print(nam,"Dictionary<Int8, Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int8, Int16>:
            print(nam,"Dictionary<Int8, Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int8, Int32>:
            print(nam,"Dictionary<Int8, Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int8, Int64>:
            print(nam,"Dictionary<Int8, Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int16, String>:
            print(nam,"Dictionary<Int16, String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int16, Bool>:
            print(nam,"Dictionary<Int16, Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int16, Float32>:
            print(nam,"Dictionary<Int16, Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int16, Float64>:
            print(nam,"Dictionary<Int16, Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int16, Int8>:
            print(nam,"Dictionary<Int16, Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int16, Int16>:
            print(nam,"Dictionary<Int16, Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int16, Int32>:
            print(nam,"Dictionary<Int16, Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int16, Int64>:
            print(nam,"Dictionary<Int16, Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int32, String>:
            print(nam,"Dictionary<Int32, String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int32, Bool>:
            print(nam,"Dictionary<Int32, Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int32, Float32>:
            print(nam,"Dictionary<Int32, Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int32, Float64>:
            print(nam,"Dictionary<Int32, Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int32, Int8>:
            print(nam,"Dictionary<Int32, Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int32, Int16>:
            print(nam,"Dictionary<Int32, Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int32, Int32>:
            print(nam,"Dictionary<Int32, Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int32, Int64>:
            print(nam,"Dictionary<Int32, Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int64, String>:
            print(nam,"Dictionary<Int64, String>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_string(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int64, Bool>:
            print(nam,"Dictionary<Int64, Bool>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int64, Float32>:
            print(nam,"Dictionary<Int64, Float32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_float(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int64, Float64>:
            print(nam,"Dictionary<Int64, Float64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_double(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int64, Int8>:
            print(nam,"Dictionary<Int64, Int8>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int8(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int64, Int16>:
            print(nam,"Dictionary<Int64, Int16>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int16(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int64, Int32>:
            print(nam,"Dictionary<Int64, Int32>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int32(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int64, Int64>:
            print(nam,"Dictionary<Int64, Int64>",vs)
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int64(collection, v)
            }
            cass_statement_bind_collection_by_name(statement, nam, collection)

        default:
            print("*** name=\(nam), type of=\(type(of:value!)), Any=\(value!)")
            fatalError("Invalid argument: name=\(nam), type of=\(type(of:value!)), Any=\(value!)")
        }
    }
}

extension CassConsistency: CustomStringConvertible {
    public var description: String {
//        switch self {
//        case CASS_CONSISTENCY_UNKNOWN: return "CASS_CONSISTENCY_UNKNOWN"
//        case CASS_CONSISTENCY_ANY: return "CASS_CONSISTENCY_ANY"
//        case CASS_CONSISTENCY_ONE: return "CASS_CONSISTENCY_ONE"
//        case CASS_CONSISTENCY_TWO: return "CASS_CONSISTENCY_TWO"
//        case CASS_CONSISTENCY_THREE: return "CASS_CONSISTENCY_THREE"
//        case CASS_CONSISTENCY_QUORUM: return "CASS_CONSISTENCY_QUORUM"
//        case CASS_CONSISTENCY_ALL: return "CASS_CONSISTENCY_ALL"
//        case CASS_CONSISTENCY_LOCAL_QUORUM: return "CASS_CONSISTENCY_LOCAL_QUORUM"
//        case CASS_CONSISTENCY_EACH_QUORUM: return "CASS_CONSISTENCY_EACH_QUORUM"
//        case CASS_CONSISTENCY_SERIAL: return "CASS_CONSISTENCY_SERIAL"
//        case CASS_CONSISTENCY_LOCAL_SERIAL: return "CASS_CONSISTENCY_LOCAL_SERIAL"
//        case CASS_CONSISTENCY_LOCAL_ONE: return "CASS_CONSISTENCY_LOCAL_ONE"
//        default: fatalError()
//        }
        if let str = String(validatingUTF8: cass_consistency_string(self)) {
            return str
        } else {
            fatalError() // ne devrait pas se produire
        }
    }
    public static func fromString(_ consistency: String) -> CassConsistency {
        switch consistency {
        case "CASS_CONSISTENCY_UNKNOWN": return CASS_CONSISTENCY_UNKNOWN
        case "CASS_CONSISTENCY_ANY": return CASS_CONSISTENCY_ANY
        case "CASS_CONSISTENCY_ONE": return CASS_CONSISTENCY_ONE
        case "CASS_CONSISTENCY_TWO": return CASS_CONSISTENCY_TWO
        case "CASS_CONSISTENCY_THREE": return CASS_CONSISTENCY_THREE
        case "CASS_CONSISTENCY_QUORUM": return CASS_CONSISTENCY_QUORUM
        case "CASS_CONSISTENCY_ALL": return CASS_CONSISTENCY_ALL
        case "CASS_CONSISTENCY_LOCAL_QUORUM": return CASS_CONSISTENCY_LOCAL_QUORUM
        case "CASS_CONSISTENCY_EACH_QUORUM": return CASS_CONSISTENCY_EACH_QUORUM
        case "CASS_CONSISTENCY_SERIAL": return CASS_CONSISTENCY_SERIAL
        case "CASS_CONSISTENCY_LOCAL_SERIAL": return CASS_CONSISTENCY_LOCAL_SERIAL
        case "CASS_CONSISTENCY_LOCAL_ONE": return CASS_CONSISTENCY_LOCAL_ONE
        default: fatalError()
        }
    }
}

extension CassWriteType: CustomStringConvertible {
    public var description: String {
//        switch self {
//        case CASS_WRITE_TYPE_UNKNOWN: return "CASS_WRITE_TYPE_UNKNOWN"
//        case CASS_WRITE_TYPE_SIMPLE: return "CASS_WRITE_TYPE_SIMPLE"
//        case CASS_WRITE_TYPE_BATCH: return "CASS_WRITE_TYPE_BATCH"
//        case CASS_WRITE_TYPE_UNLOGGED_BATCH: return "CASS_WRITE_TYPE_UNLOGGED_BATCH"
//        case CASS_WRITE_TYPE_COUNTER: return "CASS_WRITE_TYPE_COUNTER"
//        case CASS_WRITE_TYPE_BATCH_LOG: return "CASS_WRITE_TYPE_BATCH_LOG"
//        case CASS_WRITE_TYPE_CAS: return "CASS_WRITE_TYPE_CAS"
//        default: fatalError()
//        }
        if let str = String(validatingUTF8: cass_write_type_string(self)) {
            return str
        } else {
            fatalError() // ne devrait pas se produire
        }
    }
}

extension CassColumnType: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_COLUMN_TYPE_REGULAR: return "CASS_COLUMN_TYPE_REGULAR"
        case CASS_COLUMN_TYPE_PARTITION_KEY: return "CASS_COLUMN_TYPE_PARTITION_KEY"
        case CASS_COLUMN_TYPE_CLUSTERING_KEY: return "CASS_COLUMN_TYPE_CLUSTERING_KEY"
        case CASS_COLUMN_TYPE_STATIC: return "CASS_COLUMN_TYPE_STATIC"
        case CASS_COLUMN_TYPE_COMPACT_VALUE: return "CASS_COLUMN_TYPE_COMPACT_VALUE"
        default: fatalError()
        }
    }
}

extension CassIndexType: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_INDEX_TYPE_UNKNOWN: return "CASS_INDEX_TYPE_UNKNOWN"
        case CASS_INDEX_TYPE_KEYS: return "CASS_INDEX_TYPE_KEYS"
        case CASS_INDEX_TYPE_CUSTOM: return "CASS_INDEX_TYPE_CUSTOM"
        case CASS_INDEX_TYPE_COMPOSITES: return "CASS_INDEX_TYPE_COMPOSITES"
        default: fatalError()
        }
    }
}

extension CassValueType: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_VALUE_TYPE_UNKNOWN: return "CASS_VALUE_TYPE_UNKNOWN"
        case CASS_VALUE_TYPE_CUSTOM: return "CASS_VALUE_TYPE_CUSTOM"
        case CASS_VALUE_TYPE_ASCII: return "CASS_VALUE_TYPE_ASCII"
        case CASS_VALUE_TYPE_BIGINT: return "CASS_VALUE_TYPE_BIGINT"
        case CASS_VALUE_TYPE_BLOB: return "CASS_VALUE_TYPE_BLOB"
        case CASS_VALUE_TYPE_BOOLEAN: return "CASS_VALUE_TYPE_BOOLEAN"
        case CASS_VALUE_TYPE_COUNTER: return "CASS_VALUE_TYPE_COUNTER"
        case CASS_VALUE_TYPE_DECIMAL: return "CASS_VALUE_TYPE_DECIMAL"
        case CASS_VALUE_TYPE_DOUBLE: return "CASS_VALUE_TYPE_DOUBLE"
        case CASS_VALUE_TYPE_FLOAT: return "CASS_VALUE_TYPE_FLOAT"
        case CASS_VALUE_TYPE_INT: return "CASS_VALUE_TYPE_INT"
        case CASS_VALUE_TYPE_TEXT: return "CASS_VALUE_TYPE_TEXT"
        case CASS_VALUE_TYPE_TIMESTAMP: return "CASS_VALUE_TYPE_TIMESTAMP"
        case CASS_VALUE_TYPE_UUID: return "CASS_VALUE_TYPE_UUID"
        case CASS_VALUE_TYPE_VARCHAR: return "CASS_VALUE_TYPE_VARCHAR"
        case CASS_VALUE_TYPE_VARINT: return "CASS_VALUE_TYPE_VARINT"
        case CASS_VALUE_TYPE_TIMEUUID: return "CASS_VALUE_TYPE_TIMEUUID"
        case CASS_VALUE_TYPE_INET: return "CASS_VALUE_TYPE_INET"
        case CASS_VALUE_TYPE_DATE: return "CASS_VALUE_TYPE_DATE"
        case CASS_VALUE_TYPE_TIME: return "CASS_VALUE_TYPE_TIME"
        case CASS_VALUE_TYPE_SMALL_INT: return "CASS_VALUE_TYPE_SMALL_INT"
        case CASS_VALUE_TYPE_TINY_INT: return "CASS_VALUE_TYPE_TINY_INT"
        case CASS_VALUE_TYPE_DURATION: return "CASS_VALUE_TYPE_DURATION"
        case CASS_VALUE_TYPE_LIST: return "CASS_VALUE_TYPE_LIST"
        case CASS_VALUE_TYPE_MAP: return "CASS_VALUE_TYPE_MAP"
        case CASS_VALUE_TYPE_SET: return "CASS_VALUE_TYPE_SET"
        case CASS_VALUE_TYPE_UDT: return "CASS_VALUE_TYPE_UDT"
        case CASS_VALUE_TYPE_TUPLE: return "CASS_VALUE_TYPE_TUPLE"
        default: fatalError()
        }
    }
}

extension CassClusteringOrder: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_CLUSTERING_ORDER_NONE: return "CASS_CLUSTERING_ORDER_NONE"
        case CASS_CLUSTERING_ORDER_ASC: return "CASS_CLUSTERING_ORDER_ASC"
        case CASS_CLUSTERING_ORDER_DESC: return "CASS_CLUSTERING_ORDER_DESC"
        default: fatalError()
        }
    }
}

extension CassCollectionType: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_COLLECTION_TYPE_LIST: return "CASS_COLLECTION_TYPE_LIST"
        case CASS_COLLECTION_TYPE_MAP: return "CASS_COLLECTION_TYPE_MAP"
        case CASS_COLLECTION_TYPE_SET: return "CASS_COLLECTION_TYPE_SET"
        default: fatalError()
        }
    }
}

extension CassIteratorType: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_ITERATOR_TYPE_RESULT: return "CASS_ITERATOR_TYPE_RESULT"
        case CASS_ITERATOR_TYPE_ROW: return "CASS_ITERATOR_TYPE_ROW"
        case CASS_ITERATOR_TYPE_COLLECTION: return "CASS_ITERATOR_TYPE_COLLECTION"
        case CASS_ITERATOR_TYPE_MAP: return "CASS_ITERATOR_TYPE_MAP"
        case CASS_ITERATOR_TYPE_TUPLE: return "CASS_ITERATOR_TYPE_TUPLE"
        case CASS_ITERATOR_TYPE_USER_TYPE_FIELD: return "CASS_ITERATOR_TYPE_USER_TYPE_FIELD"
        case CASS_ITERATOR_TYPE_META_FIELD: return "CASS_ITERATOR_TYPE_META_FIELD"
        case CASS_ITERATOR_TYPE_KEYSPACE_META: return "CASS_ITERATOR_TYPE_KEYSPACE_META"
        case CASS_ITERATOR_TYPE_TABLE_META: return "CASS_ITERATOR_TYPE_TABLE_META"
        case CASS_ITERATOR_TYPE_TYPE_META: return "CASS_ITERATOR_TYPE_TYPE_META"
        case CASS_ITERATOR_TYPE_FUNCTION_META: return "CASS_ITERATOR_TYPE_FUNCTION_META"
        case CASS_ITERATOR_TYPE_AGGREGATE_META: return "CASS_ITERATOR_TYPE_AGGREGATE_META"
        case CASS_ITERATOR_TYPE_COLUMN_META: return "CASS_ITERATOR_TYPE_COLUMN_META"
        case CASS_ITERATOR_TYPE_INDEX_META: return "CASS_ITERATOR_TYPE_INDEX_META"
        case CASS_ITERATOR_TYPE_MATERIALIZED_VIEW_META: return "CASS_ITERATOR_TYPE_MATERIALIZED_VIEW_META"
        default: fatalError()
        }
    }
}

extension CassLogLevel: CustomStringConvertible {
    public var description: String {
//        switch self {
//        case CASS_LOG_DISABLED: return "CASS_LOG_DISABLED"
//        case CASS_LOG_CRITICAL: return "CASS_LOG_CRITICAL"
//        case CASS_LOG_ERROR: return "CASS_LOG_ERROR"
//        case CASS_LOG_WARN: return "CASS_LOG_WARN"
//        case CASS_LOG_INFO: return "CASS_LOG_INFO"
//        case CASS_LOG_DEBUG: return "CASS_LOG_DEBUG"
//        case CASS_LOG_TRACE: return "CASS_LOG_TRACE"
//        default: fatalError()
//        }
        if let str = String(validatingUTF8: cass_log_level_string(self)) {
            return str
        } else {
            fatalError() // ne devrait pas se produire
        }
    }
}

extension CassSslVerifyFlags: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_SSL_VERIFY_NONE: return "CASS_SSL_VERIFY_NONE"
        case CASS_SSL_VERIFY_PEER_CERT: return "CASS_SSL_VERIFY_PEER_CERT"
        case CASS_SSL_VERIFY_PEER_IDENTITY: return "CASS_SSL_VERIFY_PEER_IDENTITY"
        case CASS_SSL_VERIFY_PEER_IDENTITY_DNS: return "CASS_SSL_VERIFY_PEER_IDENTITY_DNS"
        default: fatalError()
        }
    }
}

extension CassErrorSource: CustomStringConvertible {
    public var description: String {
        switch self {
        case CASS_ERROR_SOURCE_NONE: return "CASS_ERROR_SOURCE_NONE"
        case CASS_ERROR_SOURCE_LIB: return "CASS_ERROR_SOURCE_LIB"
        case CASS_ERROR_SOURCE_SERVER: return "CASS_ERROR_SOURCE_SERVER"
        case CASS_ERROR_SOURCE_SSL: return "CASS_ERROR_SOURCE_SSL"
        case CASS_ERROR_SOURCE_COMPRESSION: return "CASS_ERROR_SOURCE_COMPRESSION"
        default: fatalError()
        }
    }
}

extension CassError: CustomStringConvertible {
    public var description: String {
//        switch self {
//        case CASS_OK: return "CASS_OK"
//        case CASS_ERROR_LIB_BAD_PARAMS: return "CASS_ERROR_LIB_BAD_PARAMS"
//        case CASS_ERROR_LIB_NO_STREAMS: return "CASS_ERROR_LIB_NO_STREAMS"
//        case CASS_ERROR_LIB_UNABLE_TO_INIT: return "CASS_ERROR_LIB_UNABLE_TO_INIT"
//        case CASS_ERROR_LIB_MESSAGE_ENCODE: return "CASS_ERROR_LIB_MESSAGE_ENCODE"
//        case CASS_ERROR_LIB_HOST_RESOLUTION: return "CASS_ERROR_LIB_HOST_RESOLUTION"
//        case CASS_ERROR_LIB_UNEXPECTED_RESPONSE: return "CASS_ERROR_LIB_UNEXPECTED_RESPONSE"
//        case CASS_ERROR_LIB_REQUEST_QUEUE_FULL: return "CASS_ERROR_LIB_REQUEST_QUEUE_FULL"
//        case CASS_ERROR_LIB_NO_AVAILABLE_IO_THREAD: return "CASS_ERROR_LIB_NO_AVAILABLE_IO_THREAD"
//        case CASS_ERROR_LIB_WRITE_ERROR: return "CASS_ERROR_LIB_WRITE_ERROR"
//        case CASS_ERROR_LIB_NO_HOSTS_AVAILABLE: return "CASS_ERROR_LIB_NO_HOSTS_AVAILABLE"
//        case CASS_ERROR_LIB_INDEX_OUT_OF_BOUNDS: return "CASS_ERROR_LIB_INDEX_OUT_OF_BOUNDS"
//        case CASS_ERROR_LIB_INVALID_ITEM_COUNT: return "CASS_ERROR_LIB_INVALID_ITEM_COUNT"
//        case CASS_ERROR_LIB_INVALID_VALUE_TYPE: return "CASS_ERROR_LIB_INVALID_VALUE_TYPE"
//        case CASS_ERROR_LIB_REQUEST_TIMED_OUT: return "CASS_ERROR_LIB_REQUEST_TIMED_OUT"
//        case CASS_ERROR_LIB_UNABLE_TO_SET_KEYSPACE: return "CASS_ERROR_LIB_UNABLE_TO_SET_KEYSPACE"
//        case CASS_ERROR_LIB_CALLBACK_ALREADY_SET: return "CASS_ERROR_LIB_CALLBACK_ALREADY_SET"
//        case CASS_ERROR_LIB_INVALID_STATEMENT_TYPE: return "CASS_ERROR_LIB_INVALID_STATEMENT_TYPE"
//        case CASS_ERROR_LIB_NAME_DOES_NOT_EXIST: return "CASS_ERROR_LIB_NAME_DOES_NOT_EXIST"
//        case CASS_ERROR_LIB_UNABLE_TO_DETERMINE_PROTOCOL: return "CASS_ERROR_LIB_UNABLE_TO_DETERMINE_PROTOCOL"
//        case CASS_ERROR_LIB_NULL_VALUE: return "CASS_ERROR_LIB_NULL_VALUE"
//        case CASS_ERROR_LIB_NOT_IMPLEMENTED: return "CASS_ERROR_LIB_NOT_IMPLEMENTED"
//        case CASS_ERROR_LIB_UNABLE_TO_CONNECT: return "CASS_ERROR_LIB_UNABLE_TO_CONNECT"
//        case CASS_ERROR_LIB_UNABLE_TO_CLOSE: return "CASS_ERROR_LIB_UNABLE_TO_CLOSE"
//        case CASS_ERROR_LIB_NO_PAGING_STATE: return "CASS_ERROR_LIB_NO_PAGING_STATE"
//        case CASS_ERROR_LIB_PARAMETER_UNSET: return "CASS_ERROR_LIB_PARAMETER_UNSET"
//        case CASS_ERROR_LIB_INVALID_ERROR_RESULT_TYPE: return "CASS_ERROR_LIB_INVALID_ERROR_RESULT_TYPE"
//        case CASS_ERROR_LIB_INVALID_FUTURE_TYPE: return "CASS_ERROR_LIB_INVALID_FUTURE_TYPE"
//        case CASS_ERROR_LIB_INTERNAL_ERROR: return "CASS_ERROR_LIB_INTERNAL_ERROR"
//        case CASS_ERROR_LIB_INVALID_CUSTOM_TYPE: return "CASS_ERROR_LIB_INVALID_CUSTOM_TYPE"
//        case CASS_ERROR_LIB_INVALID_DATA: return "CASS_ERROR_LIB_INVALID_DATA"
//        case CASS_ERROR_LIB_NOT_ENOUGH_DATA: return "CASS_ERROR_LIB_NOT_ENOUGH_DATA"
//        case CASS_ERROR_LIB_INVALID_STATE: return "CASS_ERROR_LIB_INVALID_STATE"
//        case CASS_ERROR_LIB_NO_CUSTOM_PAYLOAD: return "CASS_ERROR_LIB_NO_CUSTOM_PAYLOAD"
//
//        case CASS_ERROR_SERVER_SERVER_ERROR: return "CASS_ERROR_SERVER_SERVER_ERROR"
//        case CASS_ERROR_SERVER_PROTOCOL_ERROR: return "CASS_ERROR_SERVER_PROTOCOL_ERROR"
//        case CASS_ERROR_SERVER_BAD_CREDENTIALS: return "CASS_ERROR_SERVER_BAD_CREDENTIALS"
//        case CASS_ERROR_SERVER_UNAVAILABLE: return "CASS_ERROR_SERVER_UNAVAILABLE"
//        case CASS_ERROR_SERVER_OVERLOADED: return "CASS_ERROR_SERVER_OVERLOADED"
//        case CASS_ERROR_SERVER_IS_BOOTSTRAPPING: return "CASS_ERROR_SERVER_IS_BOOTSTRAPPING"
//        case CASS_ERROR_SERVER_TRUNCATE_ERROR: return "CASS_ERROR_SERVER_TRUNCATE_ERROR"
//        case CASS_ERROR_SERVER_WRITE_TIMEOUT: return "CASS_ERROR_SERVER_WRITE_TIMEOUT"
//        case CASS_ERROR_SERVER_READ_TIMEOUT: return "CASS_ERROR_SERVER_READ_TIMEOUT"
//        case CASS_ERROR_SERVER_READ_FAILURE: return "CASS_ERROR_SERVER_READ_FAILURE"
//        case CASS_ERROR_SERVER_FUNCTION_FAILURE: return "CASS_ERROR_SERVER_FUNCTION_FAILURE"
//        case CASS_ERROR_SERVER_WRITE_FAILURE: return "CASS_ERROR_SERVER_WRITE_FAILURE"
//        case CASS_ERROR_SERVER_SYNTAX_ERROR: return "CASS_ERROR_SERVER_SYNTAX_ERROR"
//        case CASS_ERROR_SERVER_UNAUTHORIZED: return "CASS_ERROR_SERVER_UNAUTHORIZED"
//        case CASS_ERROR_SERVER_INVALID_QUERY: return "CASS_ERROR_SERVER_INVALID_QUERY"
//        case CASS_ERROR_SERVER_CONFIG_ERROR: return "CASS_ERROR_SERVER_CONFIG_ERROR"
//        case CASS_ERROR_SERVER_ALREADY_EXISTS: return "CASS_ERROR_SERVER_ALREADY_EXISTS"
//        case CASS_ERROR_SERVER_UNPREPARED: return "CASS_ERROR_SERVER_UNPREPARED"
//
//        case CASS_ERROR_SSL_INVALID_CERT: return "CASS_ERROR_SSL_INVALID_CERT"
//        case CASS_ERROR_SSL_INVALID_PRIVATE_KEY: return "CASS_ERROR_SSL_INVALID_PRIVATE_KEY"
//        case CASS_ERROR_SSL_NO_PEER_CERT: return "CASS_ERROR_SSL_NO_PEER_CERT"
//        case CASS_ERROR_SSL_INVALID_PEER_CERT: return "CASS_ERROR_SSL_INVALID_PEER_CERT"
//        case CASS_ERROR_SSL_IDENTITY_MISMATCH: return "CASS_ERROR_SSL_IDENTITY_MISMATCH"
//        case CASS_ERROR_SSL_PROTOCOL_ERROR: return "CASS_ERROR_SSL_PROTOCOL_ERROR"
//
//        default: fatalError()
//        }
        if let str = String(validatingUTF8: cass_error_desc(self)) {
            return str
        } else {
            fatalError() // ne devrait pas se produire
        }
    }
}

