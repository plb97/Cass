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
        self.session = session
    }
    deinit {
        cass_session_free(session)
    }
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
            fatalError("Ne devrait pas arriver")
        }
    }
    public func execute(_ statement: Statement) -> Future {
        if let future = cass_session_execute(session, statement.statement) {
            return StatementFuture(statement: statement, future: future)
        } else {
            fatalError("Ne devrait pas arriver")
        }
    }
    public func execute(batch: Batch) -> Future {
        if let future = cass_session_execute_batch(session, batch.batch) {
            return BatchFuture(future)
        } else {
            fatalError("Ne devrait pas arriver")
        }
    }
    public func connect(_ cluster: Cluster, listener: Listener) {
        if let future = cass_session_connect(session, cluster.cluster) {
            Listener.setCallback(future: future, listener: listener)
        } else {
            fatalError("Ne devrait pas arriver")
        }
    }
    public func execute(_ statement: Statement, listener: Listener) {
        if let future = cass_session_execute(session, statement.statement) {
            Listener.setCallback(future: future, listener: listener)
        } else {
            fatalError("Ne devrait pas arriver")
        }
    }
    public func prepare(_ query: String) -> Future {
        if let future = cass_session_prepare(session, query) {
            return Future(future)
        } else {
            fatalError("Ne devrait pas arriver")
        }
    }
    public var schemaMeta: SchemaMeta { get {return SchemaMeta(cass_session_get_schema_meta(session))} }
    public func close() -> Future {
        if let future = cass_session_close(session) {
            return Future(future)
        } else {
            fatalError("Ne devrait pas arriver")
        }
    }
}

