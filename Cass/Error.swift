//
//  Error.swift
//  Cass
//
//  Created by Philippe on 23/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

//import Foundation

public
typealias Checker_f = (Error?) -> Bool
func checkError(_ err_: Error?) -> Bool {
    if let err = err_?.error {
        print(err)
        fatalError(err)
    }
    return true
}

func message(_ rc: CassError,_ pfx: String = "") ->  String? {
    if CASS_OK == rc {
        return nil
    } else {
        return pfx+rc.description
    }
}

public
class Error {
    var msg_: String?
    init(_ msg_: String? = nil) {
        self.msg_ = msg_
    }
    public var error: String? {
        get { return msg_}
        set (msg_) { self.msg_ = msg_}
    }
    public func check(checker: Checker_f = checkError) -> Bool {
        return checker(self)
    }
}


