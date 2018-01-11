//
//  Error.swift
//  Cass
//
//  Created by Philippe on 23/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

func message(_ rc: CassError,_ pfx: String = "") ->  String? {
    if CASS_OK == rc {
        return nil
    } else {
        return pfx+rc.description
    }
}

public
protocol Checker {
    func check(checker: (Status?) -> Bool) -> Bool
}
func checkStatus(_ err_: Status?) -> Bool {
    if let err = err_?.error {
        print(err)
        fatalError(err)
    }
    return true
}

public
class Status: Checker {
    var msg_: String?
    init(_ msg_: String? = nil) {
        self.msg_ = msg_
    }
    public var error: String? {
        get { return msg_}
        set (msg_) { self.msg_ = msg_}
    }
    @discardableResult
    public func check(checker: ((Status?) -> Bool) = checkStatus) -> Bool {
        return checker(self)
    }
}


