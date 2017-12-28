//
//  Tuple.swift
//  Cass
//
//  Created by Philippe on 27/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

import Foundation

public
class Tuple: Error {
    let tuple: OpaquePointer
    public init(itemCount: Int) {
        print("init Tuple")
        tuple = cass_tuple_new(itemCount)
        super.init()
    }
    public init(dataType: DataType) {
        print("init Tuple")
        tuple = cass_tuple_new_from_data_type(dataType.data_type)
        super.init()
    }
    deinit {
        print("deinit Tuple")
        cass_tuple_free(tuple)
    }
    public func setNull(index: Int) -> Tuple {
        msg_ = message(cass_tuple_set_null(tuple, index))
        return self
    }
    public func setInt8(index: Int, value: Int8) -> Tuple {
        msg_ = message(cass_tuple_set_int8(tuple, index, value))
        return self
    }
    public func setInt16(index: Int, value: Int16) -> Tuple {
        msg_ = message(cass_tuple_set_int16(tuple, index, value))
        return self
    }
    public func setInt32(index: Int, value: Int32) -> Tuple {
        msg_ = message(cass_tuple_set_int32(tuple, index, value))
        return self
    }
    public func setUInt32(index: Int, value: UInt32) -> Tuple {
        msg_ = message(cass_tuple_set_uint32(tuple, index, value))
        return self
    }
    public func setInt64(index: Int, value: Int64) -> Tuple {
        msg_ = message(cass_tuple_set_int64(tuple, index, value))
        return self
    }
    public func setFloat(index: Int, value: Float) -> Tuple {
        msg_ = message(cass_tuple_set_float(tuple, index, value))
        return self
    }
    public func setDouble(index: Int, value: Double) -> Tuple {
        msg_ = message(cass_tuple_set_double(tuple, index, value))
        return self
    }
    public func setBool(index: Int, value: Bool) -> Tuple {
        msg_ = message(cass_tuple_set_bool(tuple, index, value ? cass_true : cass_false))
        return self
    }
    public func setString(index: Int, value: String) -> Tuple {
        msg_ = message(cass_tuple_set_string(tuple, index, value))
        return self
    }
    public func setBytes(index: Int, value: Array<UInt8>) -> Tuple {
        msg_ = message(cass_tuple_set_bytes(tuple, index, value, value.count))
        return self
    }
    //setCustom
    public func setUuid(index: Int, value: UUID) -> Tuple {
        msg_ = message(cass_tuple_set_uuid(tuple, index, uuid_(uuid:value)))
        return self
    }
    public func setInet(index: Int, value: Inet) -> Tuple {
        msg_ = message(cass_tuple_set_inet(tuple, index, value.addr))
        return self
    }
    //setDecimal
    //setCollection
    public func setTuple(index: Int, value: Tuple) -> Tuple {
        msg_ = message(cass_tuple_set_tuple(tuple, index, value.tuple))
        return self
    }
}
