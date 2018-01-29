//
//  Session.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

public
class Session {
    let session: OpaquePointer
    public init(_ session: OpaquePointer = cass_session_new()) {
        print("init session \(session)")
        self.session = session
    }
    deinit {
        print("deinit session \(session)")
        cass_session_free(session)
    }
    public var schemaMeta: SchemaMeta {return SchemaMeta(cass_session_get_schema_meta(session))}
    @discardableResult
    public func connect(_ cluster: Cluster, keyspace keyspace_: String? = nil) -> Future {
        var future_: OpaquePointer?
        if let keyspace = keyspace_ {
            future_ = cass_session_connect_keyspace(session, cluster.cluster, keyspace)
        } else {
            future_ = cass_session_connect(session, cluster.cluster)
        }
        if let future = future_ {
            return Future(future)
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    public func prepare(_ query: String) -> Future {
        if let future = cass_session_prepare(session, query) {
            return Future(future)
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    public func execute(_ statement: Statement) -> Future {
        if let future = cass_session_execute(session, statement.statement) {
            return StatementFuture(statement: statement, future: future)
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    public func execute(batch: Batch) -> Future {
        if let future = cass_session_execute_batch(session, batch.batch) {
            return Future(future)
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    @discardableResult
    public func connect(_ cluster: Cluster, callback: Callback) -> UnsafeMutableRawPointer? {
        if let future = cass_session_connect(session, cluster.cluster) {
            return Callback.setCallback(future: future, callback: callback)
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    @discardableResult
    public func execute(_ statement: Statement, callback: Callback) -> UnsafeMutableRawPointer? {
        if let future = cass_session_execute(session, statement.statement) {
            return Callback.setCallback(future: future, callback: callback)
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    @discardableResult
    public func close() -> Future {
        if let future = cass_session_close(session) {
            return Future(future)
        } else {
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
}

