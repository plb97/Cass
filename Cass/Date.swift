//
//  Date.swift
//  Cass
//
//  Created by Philippe on 13/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

import Foundation
public typealias Date = Foundation.Date

extension Date {
    public init(timestamp: Int64) {
        self.init(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
    }
    public var timestamp: Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
