//
//  Error.swift
//  Cass
//
//  Created by Philippe on 03/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

func default_checker(_ err: Error) -> Bool {
    if !err.ok {
        print(err)
        fatalError(err.description)
    }
    return true
}

public
struct Error: CustomStringConvertible {
    let rc: CassError
    init(_ rc: CassError) {
        self.rc = rc
    }
    public var description: String {
        if ok {
            return "Ok"
        } else {
            return "**** Error: \(rc.rawValue) \(rc.description)"
        }
    }
    public var ok: Bool {
        return CASS_OK == rc
    }
    @discardableResult
    public func check(checker: ((_ err: Error) -> Bool) = default_checker) -> Bool {
        return checker(self)
    }
}
