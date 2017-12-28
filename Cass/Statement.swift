//
//  Statement.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

import Foundation

public
class SimpleStatement {
    private let query: String?
    private let _lst: [Any?]?
    private let _map: [String: Any?]?
    public init(_ query: String,_ values: Any?...) {
        print("init SimpleStatement")
        self.query = query
        self._lst = values
        self._map = nil
    }
    public init(_ query: String, map: [String: Any?]) {
        print("init SimpleStatement")
        self.query = query
        self._lst = nil
        self._map = map
    }
    deinit {
        print("deinit SimpleStatement")
    }
    func stmt() -> OpaquePointer! {
        if let lst = _lst {
            let ctr = lst.count
            //            print("ctr = \(ctr)")
            if let statement = cass_statement_new(query, ctr) {
                bind(statement, lst: lst)
                return statement
            }
        } else if let map = _map {
            let ctr = map.count
            //            print("ctr = \(ctr)")
            if let statement = cass_statement_new(query, ctr) {
                bind(statement, map: map)
                return statement
            }
        }
        return nil
    }
}

public
class PreparedStatement: Error {
    var prepared_: OpaquePointer?
    init(_ future: OpaquePointer) {
        defer {
            cass_future_free(future)
        }
        cass_future_wait(future)
        super.init(error_message(future))
        if nil == error {
            prepared_ = cass_future_get_prepared(future)
        }
        print("init PreparedStatement")
    }
    deinit {
        print("deinit PreparedStatement")
        if let prepared = prepared_ {
            cass_prepared_free(prepared)
            prepared_ = nil
        }
    }
    func stmt(_ lst: [Any?]) -> OpaquePointer! {
        if let prepared = prepared_ {
            if let statement = cass_prepared_bind(prepared) {
                bind(statement, lst: lst)
                return statement
            }
        }
        return nil
    }
    func stmt(map: [String: Any?]) -> OpaquePointer! {
        if let prepared = prepared_ {
            if let statement = cass_prepared_bind(prepared) {
                bind(statement, map: map)
                return statement
            }
        }
        return nil
    }
}

