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
        self.prepared = prepared
    }
    deinit {
        cass_prepared_free(prepared)
    }
    public var statement: PreparedStatement {
        return PreparedStatement(cass_prepared_bind(prepared)!)
    }
    public func parameterName(index: Int) -> String? {
        return String(function: cass_prepared_parameter_name, ptr: prepared, index: index)
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
