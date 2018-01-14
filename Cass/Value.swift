//
//  Value.swift
//  Cass
//
//  Created by Philippe on 22/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public
struct Value {
    let value: OpaquePointer
    init?(_ value_: OpaquePointer?) {
        if let value = value_ {
            self.value = value
        } else {
            return nil
        }
    }
    public var anyHashable: AnyHashable {
        return any as! AnyHashable
    }
    public var any: Any? {
        /*
         XX(CASS_VALUE_TYPE_CUSTOM,  0x0000, "", "") \
         XX(CASS_VALUE_TYPE_ASCII,  0x0001, "ascii", "org.apache.cassandra.db.marshal.AsciiType") \
         XX(CASS_VALUE_TYPE_BIGINT,  0x0002, "bigint", "org.apache.cassandra.db.marshal.LongType") \
         XX(CASS_VALUE_TYPE_BLOB,  0x0003, "blob", "org.apache.cassandra.db.marshal.BytesType") \
         XX(CASS_VALUE_TYPE_BOOLEAN,  0x0004, "boolean", "org.apache.cassandra.db.marshal.BooleanType") \
         XX(CASS_VALUE_TYPE_COUNTER,  0x0005, "counter", "org.apache.cassandra.db.marshal.CounterColumnType") \
         XX(CASS_VALUE_TYPE_DECIMAL,  0x0006, "decimal", "org.apache.cassandra.db.marshal.DecimalType") \
         XX(CASS_VALUE_TYPE_DOUBLE,  0x0007, "double", "org.apache.cassandra.db.marshal.DoubleType") \
         XX(CASS_VALUE_TYPE_FLOAT,  0x0008, "float", "org.apache.cassandra.db.marshal.FloatType") \
         XX(CASS_VALUE_TYPE_INT,  0x0009, "int", "org.apache.cassandra.db.marshal.Int32Type") \
         XX(CASS_VALUE_TYPE_TEXT,  0x000A, "text", "org.apache.cassandra.db.marshal.UTF8Type") \
         XX(CASS_VALUE_TYPE_TIMESTAMP,  0x000B, "timestamp", "org.apache.cassandra.db.marshal.TimestampType") \
         XX(CASS_VALUE_TYPE_UUID,  0x000C, "uuid", "org.apache.cassandra.db.marshal.UUIDType") \
         XX(CASS_VALUE_TYPE_VARCHAR,  0x000D, "varchar", "") \
         XX(CASS_VALUE_TYPE_VARINT,  0x000E, "varint", "org.apache.cassandra.db.marshal.IntegerType") \
         XX(CASS_VALUE_TYPE_TIMEUUID,  0x000F, "timeuuid", "org.apache.cassandra.db.marshal.TimeUUIDType") \
         XX(CASS_VALUE_TYPE_INET,  0x0010, "inet", "org.apache.cassandra.db.marshal.InetAddressType") \
         XX(CASS_VALUE_TYPE_DATE,  0x0011, "date", "org.apache.cassandra.db.marshal.SimpleDateType") \
         XX(CASS_VALUE_TYPE_TIME,  0x0012, "time", "org.apache.cassandra.db.marshal.TimeType") \
         XX(CASS_VALUE_TYPE_SMALL_INT,  0x0013, "smallint", "org.apache.cassandra.db.marshal.ShortType") \
         XX(CASS_VALUE_TYPE_TINY_INT,  0x0014, "tinyint", "org.apache.cassandra.db.marshal.ByteType") \
         XX(CASS_VALUE_TYPE_DURATION,  0x0015, "duration", "org.apache.cassandra.db.marshal.DurationType") \
         XX(CASS_VALUE_TYPE_LIST,  0x0020, "list", "org.apache.cassandra.db.marshal.ListType") \
         XX(CASS_VALUE_TYPE_MAP,  0x0021, "map", "org.apache.cassandra.db.marshal.MapType") \
         XX(CASS_VALUE_TYPE_SET,  0x0022, "set", "org.apache.cassandra.db.marshal.SetType") \
         XX(CASS_VALUE_TYPE_UDT,  0x0030, "", "") \
         XX(CASS_VALUE_TYPE_TUPLE,  0x0031, "tuple", "org.apache.cassandra.db.marshal.TupleType")
         */
        if isNull() {
            return nil
        }
        let typ = cass_value_type(value)
        switch typ {
        case CASS_VALUE_TYPE_TEXT, CASS_VALUE_TYPE_ASCII, CASS_VALUE_TYPE_VARCHAR:
            var data: UnsafePointer<Int8>?
            var len: Int = 0
            let rc = cass_value_get_string(value, &data, &len)
            if CASS_OK == rc {
                let res = String(text: data, len: len)
                return res!
            }
            //return nil
            fatalError("Invalid argument: error code=\(rc)")
        case CASS_VALUE_TYPE_BOOLEAN:
            var res = cass_false
            let rc = cass_value_get_bool(value , &res)
            if CASS_OK == rc {
                return cass_true == res
            }
            //return nil
            fatalError("Invalid argument: error code=\(rc)")
        case CASS_VALUE_TYPE_FLOAT:
            var res: Float32 = 0
            let rc = cass_value_get_float(value, &res)
            if CASS_OK == rc {
                return res
            }
            //return nil
            fatalError("Invalid argument: error code=\(rc)")
        case CASS_VALUE_TYPE_DOUBLE:
            var res: Float64 = 0
            let rc = cass_value_get_double(value, &res)
            if CASS_OK == rc {
                return res
            }
            //return nil
            fatalError("Invalid argument: error code=\(rc)")
        case CASS_VALUE_TYPE_INT:
            var res: Int32 = 0
            let rc = cass_value_get_int32(value, &res)
            if CASS_OK == rc {
                return res
            }
            //return nil
            fatalError("Invalid argument: error code=\(rc)")
        case CASS_VALUE_TYPE_BIGINT:
            var res: Int64 = 0
            let rc = cass_value_get_int64(value, &res)
            if CASS_OK == rc {
                return res
            }
            return nil
        case CASS_VALUE_TYPE_TIMEUUID, CASS_VALUE_TYPE_UUID:
            var cass_uuid = CassUuid()
            let rc = cass_value_get_uuid(value, &cass_uuid)
            if CASS_OK == rc {
                let res = UUID(cass_uuid: &cass_uuid)
                return res
            }
            //return nil
            fatalError("Invalid argument: error code=\(rc)")
        case CASS_VALUE_TYPE_TUPLE:
            let res = Tuple(tuple: value)
            return res
        case CASS_VALUE_TYPE_BLOB:
            var data: UnsafePointer<UInt8>?
            var len: Int = 0
            let rc = cass_value_get_bytes(value, &data, &len)
            if CASS_OK == rc {
                let res = Array(UnsafeBufferPointer(start: data, count: len))
                return res // BLOB=Array<UInt32>
            }
            //return nil
            fatalError("Invalid argument: error code=\(rc)")
        case CASS_VALUE_TYPE_TIMESTAMP:
            var timestamp: Int64 = 0
            let rc = cass_value_get_int64(value, &timestamp)
            if CASS_OK == rc {
                let res = Date(timestamp: timestamp)
                return res
            }
            //return nil
            fatalError("Invalid argument: error code=\(rc)")
         case CASS_VALUE_TYPE_DURATION:
            var months: Int32 = 0
            var days: Int32 = 0
            var nanos: Int64 = 0
            let rc = cass_value_get_duration(value, &months, &days, &nanos)
            if CASS_OK == rc {
                let res = Duration(months: months, days: days, nanos: nanos)
                return res
            }
            fatalError("Invalid argument: error code=\(rc)")
         case CASS_VALUE_TYPE_DECIMAL:
             var data: UnsafePointer<UInt8>?
             var len: Int = 0
             var scale: Int32 = 0
             let rc = cass_value_get_decimal(value, &data, &len, &scale)
             if CASS_OK == rc {
                let res = Decimal(ptr: data,length: len, scale: scale)
                return res
             }
             //return nil
             fatalError("Invalid argument: error code=\(rc)")

        case CASS_VALUE_TYPE_SET:
            let sub_type = cass_value_primary_sub_type(value)
            var res: Set<AnyHashable>
            switch sub_type {
            case CASS_VALUE_TYPE_TEXT, CASS_VALUE_TYPE_ASCII, CASS_VALUE_TYPE_VARCHAR:
                res = Set<String>()
            case CASS_VALUE_TYPE_BOOLEAN:
                res = Set<Bool>()
            case CASS_VALUE_TYPE_FLOAT:
                res = Set<Float32>()
            case CASS_VALUE_TYPE_DOUBLE:
                res = Set<Float64>()
            case CASS_VALUE_TYPE_INT:
                res = Set<Int32>()
            case CASS_VALUE_TYPE_BIGINT:
                res = Set<Int64>()
            case CASS_VALUE_TYPE_TIMEUUID, CASS_VALUE_TYPE_UUID:
                res = Set<UUID>()
            case CASS_VALUE_TYPE_TIMESTAMP:
                res = Set<Date>()
            default:
                //return nil
                fatalError("Invalid argument: sub type=\(sub_type) value=\(value)")
            }
            let it = CollectionIterator(value)
            for v in it {
                res.insert(v as! AnyHashable)
            }
            return res
        case CASS_VALUE_TYPE_LIST:
            let sub_type = cass_value_primary_sub_type(value)
            var res: Array<Any>
            switch sub_type {
            case CASS_VALUE_TYPE_TEXT, CASS_VALUE_TYPE_ASCII, CASS_VALUE_TYPE_VARCHAR:
                res = Array<String>()
            case CASS_VALUE_TYPE_BOOLEAN:
                res = Array<Bool>()
            case CASS_VALUE_TYPE_FLOAT:
                res = Array<Float32>()
            case CASS_VALUE_TYPE_DOUBLE:
                res = Array<Float64>()
            case CASS_VALUE_TYPE_INT:
                res = Array<Int32>()
            case CASS_VALUE_TYPE_BIGINT:
                res = Array<Int64>()
            case CASS_VALUE_TYPE_TIMEUUID, CASS_VALUE_TYPE_UUID:
                res = Array<UUID>()
            case CASS_VALUE_TYPE_TIMESTAMP:
                res = Array<Date>()
            default:
                //return nil
                fatalError("Invalid argument: sub type=\(sub_type) value=\(value)")
            }
            let it = CollectionIterator(value)
            for v in it {
                res.append(v)
            }
            return res
        case CASS_VALUE_TYPE_MAP:
            let key_type = cass_value_primary_sub_type(value)
            let val_type = cass_value_secondary_sub_type(value)
            var res: Dictionary<AnyHashable, Any?>
            switch key_type {
            case CASS_VALUE_TYPE_TEXT, CASS_VALUE_TYPE_ASCII, CASS_VALUE_TYPE_VARCHAR:
                switch val_type {
                case CASS_VALUE_TYPE_TEXT, CASS_VALUE_TYPE_ASCII, CASS_VALUE_TYPE_VARCHAR:
                    res = Dictionary<String, String?>()
                case CASS_VALUE_TYPE_BOOLEAN:
                    res = Dictionary<String, Bool?>()
                case CASS_VALUE_TYPE_FLOAT:
                    res = Dictionary<String, Float32?>()
                case CASS_VALUE_TYPE_DOUBLE:
                    res = Dictionary<String, Float64?>()
                case CASS_VALUE_TYPE_INT:
                    res = Dictionary<String, Int32?>()
                case CASS_VALUE_TYPE_BIGINT:
                    res = Dictionary<String, Int64?>()
                case CASS_VALUE_TYPE_TIMEUUID, CASS_VALUE_TYPE_UUID:
                    res = Dictionary<String, UUID?>()
                case CASS_VALUE_TYPE_TIMESTAMP:
                    res = Dictionary<String, Date?>()
                default:
                    //return nil
                    fatalError("Invalid argument: value type=\(val_type) value=\(value)")
                }
            case CASS_VALUE_TYPE_BOOLEAN:
                switch val_type {
                case CASS_VALUE_TYPE_TEXT, CASS_VALUE_TYPE_ASCII, CASS_VALUE_TYPE_VARCHAR:
                    res = Dictionary<Bool, String?>()
                case CASS_VALUE_TYPE_BOOLEAN:
                    res = Dictionary<Bool, Bool?>()
                case CASS_VALUE_TYPE_FLOAT:
                    res = Dictionary<Bool, Float32?>()
                case CASS_VALUE_TYPE_DOUBLE:
                    res = Dictionary<Bool, Float64?>()
                case CASS_VALUE_TYPE_INT:
                    res = Dictionary<Bool, Int32?>()
                case CASS_VALUE_TYPE_BIGINT:
                    res = Dictionary<Bool, Int64?>()
                case CASS_VALUE_TYPE_TIMEUUID, CASS_VALUE_TYPE_UUID:
                    res = Dictionary<Bool, UUID?>()
                case CASS_VALUE_TYPE_TIMESTAMP:
                    res = Dictionary<Bool, Date?>()
                default:
                    //return nil
                    fatalError("Invalid argument: value type=\(val_type) value=\(value)")
                }
            case CASS_VALUE_TYPE_FLOAT:
                switch val_type {
                case CASS_VALUE_TYPE_TEXT, CASS_VALUE_TYPE_ASCII, CASS_VALUE_TYPE_VARCHAR:
                    res = Dictionary<Float, String?>()
                case CASS_VALUE_TYPE_BOOLEAN:
                    res = Dictionary<Float, Bool?>()
                case CASS_VALUE_TYPE_FLOAT:
                    res = Dictionary<Float, Float32?>()
                case CASS_VALUE_TYPE_DOUBLE:
                    res = Dictionary<Float, Float64?>()
                case CASS_VALUE_TYPE_INT:
                    res = Dictionary<Float, Int32?>()
                case CASS_VALUE_TYPE_BIGINT:
                    res = Dictionary<Float, Int64?>()
                case CASS_VALUE_TYPE_TIMEUUID, CASS_VALUE_TYPE_UUID:
                    res = Dictionary<Float, UUID?>()
                case CASS_VALUE_TYPE_TIMESTAMP:
                    res = Dictionary<Float, Date?>()
                default:
                    //return nil
                    fatalError("Invalid argument: value type=\(val_type) value=\(value)")
                }
            case CASS_VALUE_TYPE_DOUBLE:
                switch val_type {
                case CASS_VALUE_TYPE_TEXT, CASS_VALUE_TYPE_ASCII, CASS_VALUE_TYPE_VARCHAR:
                    res = Dictionary<Double, String?>()
                case CASS_VALUE_TYPE_BOOLEAN:
                    res = Dictionary<Double, Bool?>()
                case CASS_VALUE_TYPE_FLOAT:
                    res = Dictionary<Double, Float32?>()
                case CASS_VALUE_TYPE_DOUBLE:
                    res = Dictionary<Double, Float64?>()
                case CASS_VALUE_TYPE_INT:
                    res = Dictionary<Double, Int32?>()
                case CASS_VALUE_TYPE_BIGINT:
                    res = Dictionary<Double, Int64?>()
                case CASS_VALUE_TYPE_TIMEUUID, CASS_VALUE_TYPE_UUID:
                    res = Dictionary<Double, UUID?>()
                case CASS_VALUE_TYPE_TIMESTAMP:
                    res = Dictionary<Double, Date?>()
                default:
                    //return nil
                    fatalError("Invalid argument: value type=\(val_type) value=\(value)")
                }
            case CASS_VALUE_TYPE_INT:
                switch val_type {
                case CASS_VALUE_TYPE_TEXT, CASS_VALUE_TYPE_ASCII, CASS_VALUE_TYPE_VARCHAR:
                    res = Dictionary<Int32, String?>()
                case CASS_VALUE_TYPE_BOOLEAN:
                    res = Dictionary<Int32, Bool?>()
                case CASS_VALUE_TYPE_FLOAT:
                    res = Dictionary<Int32, Float32?>()
                case CASS_VALUE_TYPE_DOUBLE:
                    res = Dictionary<Int32, Float64?>()
                case CASS_VALUE_TYPE_INT:
                    res = Dictionary<Int32, Int32?>()
                case CASS_VALUE_TYPE_BIGINT:
                    res = Dictionary<Int32, Int64?>()
                case CASS_VALUE_TYPE_TIMEUUID, CASS_VALUE_TYPE_UUID:
                    res = Dictionary<Int32, UUID?>()
                case CASS_VALUE_TYPE_TIMESTAMP:
                    res = Dictionary<Int32, Date?>()
                default:
                    //return nil
                    fatalError("Invalid argument: value type=\(val_type) value=\(value)")
                }
            case CASS_VALUE_TYPE_BIGINT:
                switch val_type {
                case CASS_VALUE_TYPE_TEXT, CASS_VALUE_TYPE_ASCII, CASS_VALUE_TYPE_VARCHAR:
                    res = Dictionary<Int64, String?>()
                case CASS_VALUE_TYPE_BOOLEAN:
                    res = Dictionary<Int64, Bool?>()
                case CASS_VALUE_TYPE_FLOAT:
                    res = Dictionary<Int64, Float32?>()
                case CASS_VALUE_TYPE_DOUBLE:
                    res = Dictionary<Int64, Float64?>()
                case CASS_VALUE_TYPE_INT:
                    res = Dictionary<Int64, Int32?>()
                case CASS_VALUE_TYPE_BIGINT:
                    res = Dictionary<Int64, Int64?>()
                case CASS_VALUE_TYPE_TIMEUUID, CASS_VALUE_TYPE_UUID:
                    res = Dictionary<Int64, UUID?>()
                case CASS_VALUE_TYPE_TIMESTAMP:
                    res = Dictionary<Int64, Date?>()
                default:
                    //return nil
                    fatalError("Invalid argument: value type=\(val_type) value=\(value)")
                }
            case CASS_VALUE_TYPE_TIMEUUID, CASS_VALUE_TYPE_UUID:
                switch val_type {
                case CASS_VALUE_TYPE_TEXT, CASS_VALUE_TYPE_ASCII, CASS_VALUE_TYPE_VARCHAR:
                    res = Dictionary<UUID, String?>()
                case CASS_VALUE_TYPE_BOOLEAN:
                    res = Dictionary<UUID, Bool?>()
                case CASS_VALUE_TYPE_FLOAT:
                    res = Dictionary<UUID, Float32?>()
                case CASS_VALUE_TYPE_DOUBLE:
                    res = Dictionary<UUID, Float64?>()
                case CASS_VALUE_TYPE_INT:
                    res = Dictionary<UUID, Int32?>()
                case CASS_VALUE_TYPE_BIGINT:
                    res = Dictionary<UUID, Int64?>()
                case CASS_VALUE_TYPE_TIMEUUID, CASS_VALUE_TYPE_UUID:
                    res = Dictionary<UUID, UUID?>()
                case CASS_VALUE_TYPE_TIMESTAMP:
                    res = Dictionary<UUID, Date?>()
                default:
                    //return nil
                    fatalError("Invalid argument: value type=\(val_type) value=\(value)")
                }
            case CASS_VALUE_TYPE_TIMESTAMP:
                switch val_type {
                case CASS_VALUE_TYPE_TEXT, CASS_VALUE_TYPE_ASCII, CASS_VALUE_TYPE_VARCHAR:
                    res = Dictionary<Date, String?>()
                case CASS_VALUE_TYPE_BOOLEAN:
                    res = Dictionary<Date, Bool?>()
                case CASS_VALUE_TYPE_FLOAT:
                    res = Dictionary<Date, Float32?>()
                case CASS_VALUE_TYPE_DOUBLE:
                    res = Dictionary<Date, Float64?>()
                case CASS_VALUE_TYPE_INT:
                    res = Dictionary<Date, Int32?>()
                case CASS_VALUE_TYPE_BIGINT:
                    res = Dictionary<Date, Int64?>()
                case CASS_VALUE_TYPE_TIMEUUID, CASS_VALUE_TYPE_UUID:
                    res = Dictionary<Date, UUID?>()
                case CASS_VALUE_TYPE_TIMESTAMP:
                    res = Dictionary<Date, Date?>()
                default:
                    //return nil
                    fatalError("Invalid argument: value type=\(val_type) value=\(value)")
                }
            default:
                //return nil
                fatalError("Invalid argument: key type=\(key_type) value=\(value)")
            }
            let it = MapIterator(value)
            for (k, v) in it {
                res[k] = v
            }
            return res
        default:
            return value
        }
    }
    public var dataType: DataType? {
        return DataType(cass_value_data_type(value))
    }

    public var int8: Int8 {
        return any as! Int8
    }
    public var int16: Int16 {
        return any as! Int16
    }
    public var int32: Int32 {
        return any as! Int32
    }
    public var uint32: UInt32 {
        return any as! UInt32
    }
    public var int64: Int64 {
        return any as! Int64
    }
    public var float: Float {
        return any as! Float
    }
    public var double: Double {
        return any as! Double
    }
    public var bool: Bool {
        return any as! Bool
    }
    public var uuid: UUID {
        return any as! UUID
    }
    public var inet: Inet {
        return any as! Inet
    }
    public var string: String {
        return any as! String
    }
    public var timestamp: Date {
        return any as! Date
    }
    public var bytes: Array<UInt8> {
        return any as! Array<UInt8>
    }
    //public var decimal: Decimal {
    //    return any as! Decimal
    //}
    //public var duration: Duration {
    //    return any as! Duration
    //}
    public var type: CassValueType {
        return cass_value_type(value)
    }
    public func isNull() -> Bool {
        return cass_true == cass_value_is_null(value)
     }
    public func isDuration() -> Bool {
        return cass_true == cass_value_is_duration(value)
    }

    public var collection: CollectionIterator {
        return CollectionIterator(value)
    }
}

extension Value: CustomStringConvertible {
    public var description: String {
        return "\(type.description): \(value)"
    }
}
