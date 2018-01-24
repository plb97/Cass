//
//  UuidGen.swift
//  Cass
//
//  Created by Philippe on 23/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public
class UuidGen {
    //static public func timestamp(uuid: UUID) -> Date {
    //    let cass_uuid = UUID2CassUuid(uuid: uuid)
    //    let date = Date(timeIntervalSince1970: TimeInterval(cass_uuid_timestamp(cass_uuid)) / 1000)
    //    return date
    //}
    static public func minFromTime(millis: UInt64) -> UUID {
        var cass_uuid = CassUuid(time_and_version: 0,clock_seq_and_node: 0)
        cass_uuid_min_from_time(millis, &cass_uuid)
        return UUID(cass: &cass_uuid)
    }
    static public func maxFromTime(millis: UInt64) -> UUID {
        var cass_uuid = CassUuid(time_and_version: 0,clock_seq_and_node: 0)
        cass_uuid_max_from_time(millis, &cass_uuid)
        return UUID(cass: &cass_uuid)
    }
    static public func fromString(_ str: String) -> UUID? {
        var cass_uuid = CassUuid(time_and_version: 0,clock_seq_and_node: 0)
        let rc = cass_uuid_from_string(str, &cass_uuid)
        if CASS_OK == rc {
            return UUID(cass: &cass_uuid)
        } else {
            return nil
        }
    }
    let uuid_gen: OpaquePointer
    public init() {
        uuid_gen = cass_uuid_gen_new()!
    }
    public init(node: UInt64) {
        uuid_gen = cass_uuid_gen_new_with_node(node)
    }
    deinit {
        cass_uuid_gen_free(uuid_gen)
    }
    public var time: UUID {
        var cass_uuid = CassUuid(time_and_version: 0,clock_seq_and_node: 0)
        cass_uuid_gen_time(uuid_gen, &cass_uuid)
        return UUID(cass: &cass_uuid)
    }
    public var random: UUID {
        var cass_uuid = CassUuid(time_and_version: 0,clock_seq_and_node: 0)
        cass_uuid_gen_random(uuid_gen, &cass_uuid)
        return UUID(cass: &cass_uuid)
    }
    public func fromTime(millis: UInt64) -> UUID {
        var cass_uuid = CassUuid(time_and_version: 0,clock_seq_and_node: 0)
        cass_uuid_gen_from_time(uuid_gen, millis, &cass_uuid)
        return UUID(cass: &cass_uuid)
    }
}


