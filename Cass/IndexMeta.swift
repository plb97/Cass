//
//  IndexMeta.swift
//  Cass
//
//  Created by Philippe on 26/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

//import Foundation

public
struct IndexMeta {
    let index_meta: OpaquePointer
    init?(_ index_meta_: OpaquePointer?) {
        if let index_meta = index_meta_ {
            self.index_meta = index_meta
        } else {
            return nil
        }
    }
    public var name: String {
        var name: UnsafePointer<Int8>?
        var name_length: Int = 0
        cass_index_meta_name(index_meta, &name, &name_length)
        if let str = utf8_string(text: name, len: name_length) {
            return str
        } else {
            fatalError("Ne devrait pas arriver")
        }
    }
}
