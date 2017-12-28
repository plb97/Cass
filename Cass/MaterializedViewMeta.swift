//
//  MaterializedViewMeta.swift
//  Cass
//
//  Created by Philippe on 22/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

//import Foundation

public
struct MaterializedViewMeta {
    let view_meta: OpaquePointer
    init?(_ view_meta_: OpaquePointer?) {
        if let view_meta = view_meta_ {
            self.view_meta = view_meta
        }
        else {
            return nil
        }
    }
}
