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
    var error_code: Error
    fileprivate init(_ statement_: OpaquePointer?) {
        error_code = Error()
        if let statement = statement_ {
        self.statement = statement
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    deinit {
    }
    public func addKeyIndex(_ index: Int) -> Statement {
        error_code = Error(cass_statement_add_key_index(statement, index))
        return self
    }
    public func resetParameters(_ count: Int) -> Statement {
        error_code = Error(cass_statement_reset_parameters(statement, count))
        return self
    }
    public func setKeyspace(_ keyspace: String) -> Statement {
        error_code = Error(cass_statement_set_keyspace(statement, keyspace))
        return self
    }
    public func setConsistency(_ consistency: Consistency) -> Statement {
        error_code = Error(cass_statement_set_consistency(statement, consistency.cass))
        return self
    }
    func setSerialConsistency(_ consistency: SerialConsistency) -> Statement {
        error_code = Error(cass_statement_set_serial_consistency(statement, consistency.cass))
        return self
    }
    public func setPagingSize(_ size: Int32) -> Statement {
        error_code = Error(cass_statement_set_paging_size(statement, size))
        return self
    }
    public func setPagingState(_ result: Result) -> Statement {
        error_code = Error(cass_statement_set_paging_state(statement, result.result))
        return self
    }
    public func setPagingState(_ token: String) -> Statement {
        error_code = Error(cass_statement_set_paging_state_token(statement, token,token.count))
        return self
    }
    public func setTimestamp(_ timestamp: Int64) -> Statement {
        error_code = Error(cass_statement_set_timestamp(statement, timestamp))
        return self
    }
    public func setRequestTimeoutMillis(_ timeout: UInt64) -> Statement {
        error_code = Error(cass_statement_set_request_timeout(statement, timeout))
        return self
    }
    public func setIsIdempotent(_ idempotent: Bool) -> Statement {
        error_code = Error(cass_statement_set_is_idempotent(statement, idempotent ? cass_true : cass_false))
        return self
    }
    public func setCustomPayload(_ payload: CustomPayload) -> Statement {
        error_code = Error(cass_statement_set_custom_payload(statement, payload.payload))
        return self
    }
    public func hasMorePages(result: Result) -> Bool {
        if result.hasMorePages {
            error_code = Error(cass_statement_set_paging_state(statement, result.result))
            return .ok == error_code
        }
        return false
    }
}

public class SimpleStatement: Statement {
    public init(_ query: String,_ values: Any?...) {
        super.init(cass_statement_new(query, values.count))
        error_code = Error(bind_lst(statement, lst: values))
    }
    public init(_ query: String, map: [String: Any?]) {
        super.init(cass_statement_new(query, map.count))
        error_code = Error(bind_map(statement, map: map))
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
        error_code = Error(bind_lst(statement, lst: values))
        return self
    }
    public func bind(map: [String: Any?]) -> PreparedStatement {
        error_code = Error(bind_map(statement, map: map))
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

