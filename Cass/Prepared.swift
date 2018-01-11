//
//  Prepared.swift
//  Cass
//
//  Created by Philippe on 10/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

//import Foundation

public class Prepared {
    let prepared: OpaquePointer
    init(_ prepared: OpaquePointer) {
        print("init Prepared")
        self.prepared = prepared
    }
    deinit {
        print("deinit Prepared")
        print("@@@@ cass_prepared_free(prepared) \(prepared)")
        cass_prepared_free(prepared)
    }
    public var statement: PreparedStatement {
        return PreparedStatement(cass_prepared_bind(prepared)!)
    }
    public func parameterName(index: Int) -> String? {
        var name: UnsafePointer<Int8>?
        var name_length: Int = 0
        let rc = cass_prepared_parameter_name(prepared, index, &name, &name_length)
        if CASS_OK == rc {
            return utf8_string(text: name, len: name_length)!
        } else {
            return nil
        }
    }
    public func dataType(index: Int) -> DataType? {
        // TODO : Do not free this reference as it is bound to the lifetime of the prepared.
        return DataType(cass_prepared_parameter_data_type(prepared, index))
    }
    public func dataType(name: String) -> DataType? {
        // TODO : Do not free this reference as it is bound to the lifetime of the prepared.
        return DataType(cass_prepared_parameter_data_type_by_name(prepared, name))
    }

}
