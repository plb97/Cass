//
//  UuidGen.swift
//  Cass
//
//  Created by Philippe on 23/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public
class UuidGen {
    let uuid_gen: OpaquePointer
    public init() {
        uuid_gen = cass_uuid_gen_new()!
    }
    deinit {
        cass_uuid_gen_free(uuid_gen)
    }
    public func time_uuid() -> UUID {
        var cass_uuid = CassUuid(time_and_version: 0,clock_seq_and_node: 0)
        cass_uuid_gen_time(uuid_gen, &cass_uuid)
        let u = CassUuid2UUID(cass_uuid: &cass_uuid)
        return u
    }
    public func timestamp(_ u: UUID) -> Date {
        let cass_uuid = UUID2CassUuid(uuid: u)
        let date = Date(timeIntervalSince1970: TimeInterval(cass_uuid_timestamp(cass_uuid)) / 1000)
        return date
    }
}
