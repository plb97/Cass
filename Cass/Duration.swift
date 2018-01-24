//
//  Duration.swift
//  Cass
//
//  Created by Philippe on 29/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public
struct Duration {
    public var months: Int32
    public var days: Int32
    public var nanos: Int64
    public init(months: Int32, days: Int32, nanos: Int64) {
        self.months = months
        self.days = days
        self.nanos = nanos
    }
    var cass: (months: Int32, days: Int32, nanos: Int64) { return (months, days, nanos) }
}
