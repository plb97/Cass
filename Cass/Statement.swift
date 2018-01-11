//
//  Statement.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

public class Statement {
    let statement: OpaquePointer
    var error_code_: Error? = nil
    fileprivate init(_ statement_: OpaquePointer?) {
        if let statement = statement_ {
        self.statement = statement
        } else {
            fatalError("Ne devrait pas arriver")
        }
    }
    deinit {
    }
    public func addKeyIndex(_ index: Int) -> Statement {
        error_code_ = Error(cass_statement_add_key_index(statement, index))
        return self
    }
    public func resetParameters(_ count: Int) -> Statement {
        error_code_ = Error(cass_statement_reset_parameters(statement, count))
        return self
    }
    public func setKeyspace(_ keyspace: String) -> Statement {
        error_code_ = Error(cass_statement_set_keyspace(statement, keyspace))
        return self
    }
    // TODO
    func setConsistency(_ consistency: CassConsistency = CASS_CONSISTENCY_LOCAL_ONE) -> Statement {
        error_code_ = Error(cass_statement_set_consistency(statement, consistency))
        return self
    }
    // TODO
    func setSerialConsistency(_ serialConsistency: CassConsistency) -> Statement {
        error_code_ = Error(cass_statement_set_serial_consistency(statement, serialConsistency))
        return self
    }
    public func setPagingSize(_ size: Int32) -> Statement {
        error_code_ = Error(cass_statement_set_paging_size(statement, size))
        return self
    }
    public func setPagingState(_ result: Result) -> Statement {
        error_code_ = Error(cass_statement_set_paging_state(statement, result.result))
        return self
    }
    public func setPagingState(_ token: String) -> Statement {
        error_code_ = Error(cass_statement_set_paging_state_token(statement, token,token.count))
        return self
    }
    public func setTimestamp(_ timestamp: Int64) -> Statement {
        error_code_ = Error(cass_statement_set_timestamp(statement, timestamp))
        return self
    }
    public func setRequestTimeoutMillis(_ timeout: UInt64) -> Statement {
        error_code_ = Error(cass_statement_set_request_timeout(statement, timeout))
        return self
    }
    public func setIsIdempotent(_ idempotent: Bool) -> Statement {
        error_code_ = Error(cass_statement_set_is_idempotent(statement, idempotent ? cass_true : cass_false))
        return self
    }
    public func setCustomPayload(_ payload: CustomPayload) -> Statement {
        error_code_ = Error(cass_statement_set_custom_payload(statement, payload.payload))
        return self
    }
    public func hasMorePages(result: Result) -> Bool {
        if result.hasMorePages {
            error_code_ = Error(cass_statement_set_paging_state(statement, result.result))
            return error_code_!.ok
        }
        return false
    }
}

public class SimpleStatement: Statement {
    public init(_ query: String,_ values: Any?...) {
        super.init(cass_statement_new(query, values.count))
        error_code_ = Error(bind_lst(statement, lst: values))
    }
    public init(_ query: String, map: [String: Any?]) {
        super.init(cass_statement_new(query, map.count))
        error_code_ = Error(bind_map(statement, map: map))
    }
    deinit {
        cass_statement_free(statement)
    }
}

public class PreparedStatement: Statement {
    override init(_ statement_: OpaquePointer?) {
        super.init(statement_)
    }
    deinit {
    }
    public func bind(_ values: Any?...) -> PreparedStatement {
        error_code_ = Error(bind_lst(statement, lst: values))
        return self
    }
    public func bind(map: [String: Any?]) -> PreparedStatement {
        error_code_ = Error(bind_map(statement, map: map))
        return self
    }
}

fileprivate func bind_lst(_ statement: OpaquePointer, lst: [Any?]) -> CassError {
    var rc = CASS_OK
    for (idx,value) in lst.enumerated() {
        if CASS_OK != rc {
            break
        }
        switch value {
        case nil:
            rc = cass_statement_bind_null(statement, idx)

        case let v as String:
            rc = cass_statement_bind_string(statement, idx,v)
        case let v as Bool:
            rc = cass_statement_bind_bool(statement, idx, (v ? cass_true : cass_false))
        case let v as Float32/*, case let v as Float*/:
            rc = cass_statement_bind_float(statement, idx, v)
        case let v as Float64/*, let v as Double*/:
            rc = cass_statement_bind_double(statement, idx, v)
        case let v as Int8 /*, let v as Int*/:
            rc = cass_statement_bind_int8(statement, idx, v)
        case let v as Int16 /*, let v as Int*/:
            rc = cass_statement_bind_int16(statement, idx, v)
        case let v as Int32 /*, let v as Int*/:
            rc = cass_statement_bind_int32(statement, idx, v)
        case let v as Int64 /*, let v as Int*/:
            rc = cass_statement_bind_int64(statement, idx, v)
        case let v as Array<UInt8>:
            rc = cass_statement_bind_bytes(statement, idx, v, v.count)

        case let v as UUID:
            rc = cass_statement_bind_uuid(statement, idx, UUID2CassUuid(uuid:v))
        case let v as Date:
            rc = cass_statement_bind_int64(statement, idx, date2Timestamp(date: v))
        case let v as Duration:
            rc = cass_statement_bind_duration(statement, idx, v.months, v.days, v.nanos)
            //        case let v as Decimal:
            //             let exp = Int32(v.exponent)
            //             let u = NSDecimalNumber(decimal: v.significand).int64Value
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
            //             let rdec = Array(dec.reversed())
            //             let val = UnsafeRawPointer(rdec).bindMemory(to: UInt8.self, capacity: n)
        //             rc = cass_statement_bind_decimal(statement, idx, val, n, -exp)
        case let vs as Set<String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Set<Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Set<Float32>/*, let vs as Set<Float>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Set<Float64>/*, let vs as Set<Double>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Set<Int8> /*, let vs as Set<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Set<Int16> /*, let vs as Set<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Set<Int32> /*, let vs as Set<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Set<Int64> /*, let vs as Set<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)

        case let vs as Array<String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Array<Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Array<Float32>/*, let v as Array<Float>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Array<Float64>/*, let vs as Array<Double>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Array<Int8> /*, let vs as Array<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Array<Int16> /*, let vs as Array<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Array<Int32> /*, let vs as Array<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Array<Int64> /*, let vs as Array<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)

        case let vs as Dictionary<String, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<String, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<String, Float32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<String, Float64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<String, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<String, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<String, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<String, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Bool, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Bool, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Bool, Float32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Bool, Float64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Bool, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Bool, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Bool, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Bool, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float32, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float32, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float32, Float32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float32, Float64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float32, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float32, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float32, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float32, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float64, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float64, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float64, Float32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float64, Float64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float64, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float64, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float64, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Float64, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int8, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int8, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int8, Float32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int8, Float64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int8, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int8, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int8, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int8, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int16, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int16, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int16, Float32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int16, Float64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int16, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int16, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int16, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int16, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int32, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int32, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int32, Float32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int32, Float64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int32, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int32, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int32, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int32, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int64, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int64, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int64, Float32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int64, Float64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int64, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int64, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int64, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let vs as Dictionary<Int64, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)

        default:
            print("*** Invalid argument: index=\(idx), type of=\(type(of:value!)), Any=\(value!)")
            rc = CASS_ERROR_LIB_INVALID_VALUE_TYPE
        }
    }
    return rc
}

fileprivate func bind_map(_ statement: OpaquePointer, map: [String: Any?]) -> CassError {
    var rc = CASS_OK
    for (nam, value) in map {
        if CASS_OK != rc {
            break
        }
        switch value {
        case nil:
            rc = cass_statement_bind_null_by_name(statement, nam)

        case let v as String:
            rc = cass_statement_bind_string_by_name(statement, nam,v)
        case let v as Bool:
            rc = cass_statement_bind_bool_by_name(statement, nam, (v ? cass_true : cass_false))
        case let v as Float32/*, let v as Float*/:
            rc = cass_statement_bind_float_by_name(statement, nam, v)
        case let v as Float64/*, let v as Double*/:
            rc = cass_statement_bind_double_by_name(statement, nam, v)
        case let v as Int8 /*, let v as Int*/:
            rc = cass_statement_bind_int8_by_name(statement, nam, v)
        case let v as Int16 /*, let v as Int*/:
            rc = cass_statement_bind_int16_by_name(statement, nam, v)
        case let v as Int32 /*, let v as Int*/:
            rc = cass_statement_bind_int32_by_name(statement, nam, v)
        case let v as Int64 /*, let v as Int*/:
            rc = cass_statement_bind_int64_by_name(statement, nam, v)
        case let v as Array<UInt8>:
            rc = cass_statement_bind_bytes_by_name(statement, nam, v, v.count)

        case let v as UUID:
            rc = cass_statement_bind_uuid_by_name(statement, nam, UUID2CassUuid(uuid:v))
        case let v as Date:
            rc = cass_statement_bind_int64_by_name(statement, nam, date2Timestamp(date: v))
        case let v as Duration:
            rc = cass_statement_bind_duration_by_name(statement, nam, v.months, v.days, v.nanos)
            //        case let v as Decimal:
            //             let exp = Int32(v.exponent)
            //             let u = NSDecimalNumber(decimal: v.significand).int64Value
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
            //             let rdec = Array(dec.reversed())
            //             let val = UnsafeRawPointer(rdec).bindMemory(to: UInt8.self, capacity: n)
        //             rc = cass_statement_bind_decimal_by_name(statement, nam, val, n, -exp)
        case let vs as Set<String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Set<Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Set<Float32>/*, let vs as Set<Float>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Set<Float64>/*, let vs as Set<Double>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Set<Int8> /*, let vs as Set<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Set<Int16> /*, let vs as Set<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Set<Int32> /*, let vs as Set<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Set<Int64> /*, let vs as Set<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_SET, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)

        case let vs as Array<String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Array<Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Array<Float32>/*, let vs as Array<Float>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Array<Float64>/*, let vs as Array<Double>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Array<Int8> /*, let vs as Array<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Array<Int16> /*, let vs as Array<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Array<Int32> /*, let vs as Array<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Array<Int64> /*, let vs as Array<Int>*/:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_LIST, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for v in vs {
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)

        case let vs as Dictionary<String, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<String, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<String, Float32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<String, Float64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<String, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<String, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<String, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<String, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_string(collection, k)
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Bool, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Bool, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Bool, Float32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Bool, Float64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Bool, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Bool, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Bool, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Bool, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_bool(collection, k ? cass_true : cass_false)
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float32, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float32, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float32, Float32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float32, Float64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float32, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float32, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float32, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float32, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_float(collection, k)
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float64, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float64, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float64, Float32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float64, Float64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float64, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float64, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float64, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Float64, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_double(collection, k)
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int8, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int8, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int8, Float32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int8, Float64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int8, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int8, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int8, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int8, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int8(collection, k)
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int16, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int16, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int16, Float32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int16, Float64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int16, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int16, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int16, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int16, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int16(collection, k)
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int32, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int32, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int32, Float32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int32, Float64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int32, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int32, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int32, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int32, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int32(collection, k)
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int64, String>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_string(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int64, Bool>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_bool(collection, v ? cass_true : cass_false)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int64, Float32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_float(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int64, Float64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_double(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int64, Int8>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int8(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int64, Int16>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int16(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int64, Int32>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int32(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let vs as Dictionary<Int64, Int64>:
            let collection = cass_collection_new(CASS_COLLECTION_TYPE_MAP, vs.count)
            defer {
                cass_collection_free(collection)
            }
            for (k, v) in vs {
                cass_collection_append_int64(collection, k)
                cass_collection_append_int64(collection, v)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)

        default:
            print("Invalid argument: name=\(nam), type of=\(type(of:value!)), Any=\(value!)")
            rc = CASS_ERROR_LIB_INVALID_VALUE_TYPE
        }
    }
    return rc
}
