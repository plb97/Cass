//
//  Version.swift
//  Cass
//
//  Created by Philippe on 22/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public
struct Version {
    let version: CassVersion
    init(_ version: CassVersion) {
        self.version = version
    }
    public func Major() -> Int32 {
        return version.major_version
    }
    public func Minor() -> Int32 {
        return version.minor_version
    }
    public func Patch() -> Int32 {
        return version.patch_version
    }
}
