//
//  UuidGen.swift
//  Cass
//
//  Created by Philippe on 23/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

import Foundation

public
class UuidGen {
    let uuid_gen = cass_uuid_gen_new()
    public init() {
        print("init UuidGen")
    }
    deinit {
        print("deinit UuidGen")
        cass_uuid_gen_free(uuid_gen)
    }
    public func time_uuid() -> UUID {
        var cass_uuid = CassUuid(time_and_version: 0,clock_seq_and_node: 0)
        cass_uuid_gen_time(uuid_gen, &cass_uuid)
        let u = uuid_(cass_uuid: &cass_uuid)
        return u
    }
    public func timestamp(_ u: UUID) -> Date {
        let cass_uuid = uuid_(uuid: u)
        let date = Date(timeIntervalSince1970: TimeInterval(cass_uuid_timestamp(cass_uuid)) / 1000)
        return date
    }
}
