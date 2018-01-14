//
//  Uuid.swift
//  Cass
//
//  Created by Philippe on 13/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

import Foundation
public typealias UUID = Foundation.UUID

extension UUID {
    init(cass_uuid: inout CassUuid) {
        self.init(time_and_version: cass_uuid.time_and_version,clock_seq_and_node: cass_uuid.clock_seq_and_node)
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
    var cassUuid: CassUuid {
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
        let pu = bytesPointer.bindMemory(to: CassUuid.self, capacity: 1)
        return pu.pointee
    }
    public var time_and_version: UInt64 {
        return self.cassUuid.time_and_version
    }
    public var clock_seq_and_node: UInt64 {
        return self.cassUuid.clock_seq_and_node
    }
    public var timestamp: UInt64 { // millisecondes
        return cass_uuid_timestamp(self.cassUuid)
    }
    public var version: UInt8 {
        return cass_uuid_version(self.cassUuid)
    }
    public var string: String {
        let len = Int(CASS_UUID_STRING_LENGTH)
        let p = UnsafeMutablePointer<Int8>.allocate(capacity: len)
        defer {
            p.deallocate(capacity: len)
        }
        p.initialize(to: 0, count:len)
        cass_uuid_string(self.cassUuid,p)
        return String(validatingUTF8: p)!
    }
}
