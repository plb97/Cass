//
//  Statement.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

import Foundation

public typealias LIST = Array<Any?>
public typealias SET = Set<AnyHashable>
public typealias MAP = Dictionary<AnyHashable, Any?>

public class Statement {
    let statement: OpaquePointer
    var error_code_: Error? = nil
    fileprivate init(_ statement_: OpaquePointer?) {
        if let statement = statement_ {
        self.statement = statement
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
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
    public func setConsistency(_ consistency: Consistency) -> Statement {
        error_code_ = Error(cass_statement_set_consistency(statement, consistency.cass))
        return self
    }
    func setSerialConsistency(_ consistency: SerialConsistency) -> Statement {
        error_code_ = Error(cass_statement_set_serial_consistency(statement, consistency.cass))
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
            return .ok == error_code_
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
            let (ptr, len) = v.cass
            rc = cass_statement_bind_string_n(statement, idx, ptr, len)
        case let v as Bool:
            rc = cass_statement_bind_bool(statement, idx, v.cass)
        case let v as Float:
            rc = cass_statement_bind_float(statement, idx, v.cass)
        case let v as Double:
            rc = cass_statement_bind_double(statement, idx, v.cass)
        case let v as Int8:
            rc = cass_statement_bind_int8(statement, idx, v.cass)
        case let v as Int16:
            rc = cass_statement_bind_int16(statement, idx, v.cass)
        case let v as Int32:
            rc = cass_statement_bind_int32(statement, idx, v.cass)
        case let v as Int:
            rc = cass_statement_bind_int32(statement, idx, v.cass)
        case let v as UInt32:
            rc = cass_statement_bind_uint32(statement, idx, v.cass)
        case let v as UInt:
            rc = cass_statement_bind_uint32(statement, idx, v.cass)
        case let v as Int64:
            rc = cass_statement_bind_int64(statement, idx, v.cass)
        case let v as Tuple:
            rc = cass_statement_bind_tuple(statement, idx, v.cass)
        case let v as Inet:
            rc = cass_statement_bind_inet(statement, idx, v.cass)
        case let v as BLOB:
            let (ptr, len) = v.cass
            rc = cass_statement_bind_bytes(statement, idx, ptr, len)

        case let v as UUID:
            rc = cass_statement_bind_uuid(statement, idx, v.cass)
        case let v as Date:
            rc = cass_statement_bind_int64(statement, idx, v.cass)
        case let v as Duration:
            let (months, days, nanos) = v.cass
            rc = cass_statement_bind_duration(statement, idx, months, days, nanos)
        case let v as Decimal:
            let (varint, varint_size, scale) = v.cass
            rc = cass_statement_bind_decimal(statement, idx, varint, varint_size, scale)
        case let v as UserType:
            print("bind UserType: idx=\(idx) v=\(v)")
            rc = cass_statement_bind_user_type(statement, idx, v.cass)
        case let v as SET:
            let collection = v.cass
            defer {
                cass_collection_free(collection)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let v as LIST:
            let collection = v.cass
            defer {
                cass_collection_free(collection)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        case let v as MAP:
            let collection = v.cass
            defer {
                cass_collection_free(collection)
            }
            rc = cass_statement_bind_collection(statement, idx, collection)
        default:
            print("*** Statement bind_lst: Invalid argument: index=\(idx), type of=\(type(of:value!)), Any=\(value!)")
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
            // ne marche pas ???
            //let (v_nam, v_len) = nam.cass
            //let (ptr, len) = v.cass
            //rc = cass_statement_bind_string_by_name_n(statement, v_nam, v_len, ptr, len)
            rc = cass_statement_bind_string_by_name(statement, nam, v)
        case let v as Bool:
            rc = cass_statement_bind_bool_by_name(statement, nam, v.cass)
        case let v as Float:
            rc = cass_statement_bind_float_by_name(statement, nam, v.cass)
        case let v as Double:
            rc = cass_statement_bind_double_by_name(statement, nam, v.cass)
        case let v as Int8:
            rc = cass_statement_bind_int8_by_name(statement, nam, v.cass)
        case let v as Int16:
            rc = cass_statement_bind_int16_by_name(statement, nam, v.cass)
        case let v as Int32:
            rc = cass_statement_bind_int32_by_name(statement, nam, v.cass)
        case let v as Int:
            rc = cass_statement_bind_int32_by_name(statement, nam, v.cass)
        case let v as UInt32:
            rc = cass_statement_bind_uint32_by_name(statement, nam, v.cass)
        case let v as UInt:
            rc = cass_statement_bind_uint32_by_name(statement, nam, v.cass)
        case let v as Int64:
            rc = cass_statement_bind_int64_by_name(statement, nam, v.cass)
        case let v as Tuple:
            rc = cass_statement_bind_tuple_by_name(statement, nam, v.cass)
        case let v as Inet:
            rc = cass_statement_bind_inet_by_name(statement, nam, v.cass)
        case let v as BLOB:
            let (ptr, len) = v.cass
            rc = cass_statement_bind_bytes_by_name(statement, nam, ptr, len)

        case let v as UUID:
            rc = cass_statement_bind_uuid_by_name(statement, nam, v.cass)
        case let v as Date:
            rc = cass_statement_bind_int64_by_name(statement, nam, v.cass)
        case let v as Duration:
            let (months, days, nanos) = v.cass
            rc = cass_statement_bind_duration_by_name(statement, nam, months, days, nanos)
        case let v as Decimal:
            let (varint, varint_size, int32) = v.cass
            rc = cass_statement_bind_decimal_by_name(statement, nam, varint, varint_size, int32)
        case let v as UserType:
            rc = cass_statement_bind_user_type_by_name(statement, nam, v.cass)

        case let v as SET:
            let collection = v.cass
            defer {
                cass_collection_free(collection)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let v as LIST:
            let collection = v.cass
            defer {
                cass_collection_free(collection)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)
        case let v as MAP:
            let collection = v.cass
            defer {
                cass_collection_free(collection)
            }
            rc = cass_statement_bind_collection_by_name(statement, nam, collection)

        default:
            print("Statement bind_map: Invalid argument: name=\(nam), type of=\(type(of:value!)), Any=\(value!)")
            rc = CASS_ERROR_LIB_INVALID_VALUE_TYPE
        }
    }
    return rc
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

protocol Cassable {
    associatedtype T
    var cass: T { get }
}
extension Int8: Cassable {
    typealias T = cass_int8_t
    var cass: cass_int8_t { return self }
}
extension Int16: Cassable {
    typealias T = cass_int16_t
    var cass: cass_int16_t { return self }
}
extension Int32: Cassable {
    typealias T = cass_int32_t
    var cass: cass_int32_t { return self }
}
extension Int: Cassable {
    typealias T = cass_int32_t
    var cass: cass_int32_t { return Int32(self) }
}
extension UInt32: Cassable {
    typealias T = cass_uint32_t
    var cass: cass_uint32_t { return self }
}
extension UInt: Cassable {
    typealias T = cass_uint32_t
    var cass: cass_uint32_t { return UInt32(self) }
}
extension Int64: Cassable {
    typealias T = cass_int64_t
    var cass: cass_int64_t { return self }
}
extension Float: Cassable {
    typealias T = cass_float_t
    var cass: cass_float_t { return self }
}
extension Double: Cassable {
    typealias T = cass_double_t
    var cass: cass_double_t { return self }
}
extension Bool: Cassable {
    typealias T = cass_bool_t
    var cass: cass_bool_t { return self ? cass_true : cass_false }
}
extension String: Cassable {
    typealias T = (UnsafePointer<Int8>, size_t)
    var cass: (UnsafePointer<Int8>, size_t) { return (UnsafePointer<Int8>(self), self.count) }
}
extension Set: Cassable {
    typealias T = OpaquePointer
    var cass: OpaquePointer { if let collection = toCollection(cass: self) { return collection } else { fatalError(FATAL_ERROR_MESSAGE)} }
}
extension Array: Cassable {
    typealias T = OpaquePointer
    var cass: OpaquePointer { if let collection = toCollection(cass: self) { return collection } else { fatalError(FATAL_ERROR_MESSAGE)} }
}
extension Dictionary: Cassable {
    typealias T = OpaquePointer
    var cass: OpaquePointer { if let collection = toCollection(cass: self) { return collection } else { fatalError(FATAL_ERROR_MESSAGE)} }
}
//extension Array: Cassable {
//    typealias Element = UInt8
//    typealias T = (UnsafePointer<UInt8>, size_t)
//    var cass: (UnsafePointer<UInt8>, size_t) { return (UnsafePointer<UInt8>(OpaquePointer(self)), self.count) }
//}
/* exemple pouvant etre utile
 protocol DataSourceDelegate : class {
    func dataSourceDidReloadData<P: DataSourceProtocol>(dataSource: P)
 }
 protocol DataSourceProtocol {
     typealias ItemType
     weak var delegate: DataSourceDelegate? { get set }
     func itemAtIndexPath(indexPath: NSIndexPath) -> ItemType?
     func dataSourceForSectionAtIndex(sectionIndex: Int) -> Self
 }
*/
