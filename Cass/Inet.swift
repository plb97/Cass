//
//  Inet.swift
//  Cass
//
//  Created by Philippe on 23/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

//import Foundation

public
struct Inet: CustomStringConvertible {
    let addr: CassInet
    init(_ addr: CassInet) {
        self.addr = addr
    }
    init(v4: Array<UInt8>) {
        self.init(cass_inet_init_v4(v4))
    }
    init(v6: Array<UInt8>) {
        self.init(cass_inet_init_v6(v6))
    }
    init(fromString str: String) {
        var output = CassInet()
        let rc = cass_inet_from_string(str, &output)
        if CASS_OK == rc {
            self.init(output)
        } else {
            fatalError(CASS_OK.description)
        }
    }
    public var description: String {
        let len = Int(CASS_INET_STRING_LENGTH+1) // = 47
        let str = UnsafeMutablePointer<Int8>.allocate(capacity: len)
        defer {
            str.deinitialize(count: len)
            str.deallocate(capacity: len)
        }
        str.initialize(to: 0, count: len)
        cass_inet_string(addr,str)
        return String(validatingUTF8: str)!
    }
}
