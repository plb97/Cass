//
//  String.swift
//  Cass
//
//  Created by Philippe on 13/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

//func utf8_string(text: UnsafePointer<Int8>? = nil, len: Int = 0) -> String? {
//    if nil == text || 0 > len {
//        return nil
//    }
//    let p = UnsafeMutablePointer<Int8>.allocate(capacity: len+1)
//    defer {
//        p.deallocate(capacity: len+1)
//    }
//    p.initialize(to: 0, count:len+1)
//    strncpy(p, text, len)
//    return String(validatingUTF8: p)
//}

typealias ptr_index_error_f = (OpaquePointer?, Int, UnsafeMutablePointer<UnsafePointer<Int8>?>?, UnsafeMutablePointer<Int>?) -> CassError
typealias ptr_error_f = (OpaquePointer?, UnsafeMutablePointer<UnsafePointer<Int8>?>?, UnsafeMutablePointer<Int>?) -> CassError
typealias ptr_f = (OpaquePointer?, UnsafeMutablePointer<UnsafePointer<Int8>?>?, UnsafeMutablePointer<Int>?) -> ()
typealias ptr_f0 = (OpaquePointer?, UnsafeMutablePointer<Int>?) -> (UnsafePointer<Int8>?)
extension String {
    init?(_ f: ptr_f0, ptr ptr_: OpaquePointer?) {
        if let ptr = ptr_ {
            var name_length: Int = 0
            let name = f(ptr, &name_length)
            self.init(ptr: name, len: name_length)!
        } else {
            return nil
        }
    }
    init?(f: ptr_f, ptr ptr_: OpaquePointer?) {
        if let ptr = ptr_ {
            var name: UnsafePointer<Int8>?
            var name_length: Int = 0
            f(ptr, &name, &name_length)
            self.init(ptr: name, len: name_length)!
        } else {
            return nil
        }
    }
    init?(f: ptr_error_f, ptr ptr_: OpaquePointer?) {
        if let ptr = ptr_ {
            var name: UnsafePointer<Int8>?
            var name_length: Int = 0
            let rc = f(ptr, &name, &name_length)
            if CASS_OK == rc {
                self.init(ptr: name, len: name_length)!
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    init?(f: ptr_index_error_f, ptr ptr_: OpaquePointer?, index: Int) {
        if let ptr = ptr_ {
            var name: UnsafePointer<Int8>?
            var name_length: Int = 0
            let rc = f(ptr, index, &name, &name_length)
            if CASS_OK == rc {
                self.init(ptr: name, len: name_length)!
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    init?(ptr: UnsafePointer<Int8>? = nil, len: Int = 0) {
        if nil == ptr || 0 > len {
            return nil
        }
        let size = len + 1
        let p = UnsafeMutablePointer<Int8>.allocate(capacity: size)
        defer {
            p.deallocate(capacity: size)
        }
        p.initialize(to: 0, count:size)
        strncpy(p, ptr, len)
        self.init(validatingUTF8: p)
    }
}
