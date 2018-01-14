//
//  IndexMeta.swift
//  Cass
//
//  Created by Philippe on 26/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

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
        if let str = String(f: cass_index_meta_name, ptr: index_meta) {
            return str
        } else {
            fatalError("Ne devrait pas arriver")
        }
    }
}
