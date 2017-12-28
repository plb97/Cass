//
//  Session.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

//import Foundation

public
class Session {
    let session: OpaquePointer
    public init(_ session: OpaquePointer = cass_session_new()) {
        self.session = session
        print("init Session")
    }
    deinit {
        print("deinit Session")
        cass_session_free(session)
    }
    public func connect(_ cluster: Cluster, keyspace keyspace_: String? = nil) -> Future {
        if let keyspace = keyspace_ {
            return Future(cass_session_connect_keyspace(session, cluster.cluster, keyspace))
        } else {
            return Future(cass_session_connect(session, cluster.cluster))
        }
    }
    public func execute(_ statement: SimpleStatement) -> Future {
        return Future(cass_session_execute(session, statement.stmt()))
    }
    public func connect(_ cluster: Cluster, listener: Listener) -> () {
        FutureBase.setCallback(cass_session_connect(session, cluster.cluster), listener)
    }
    public func execute(_ statement: SimpleStatement, listener: Listener) -> () {
        FutureBase.setCallback(cass_session_execute(session, statement.stmt()), listener)
    }
    public func prepare(_ query: String) -> PreparedStatement {
        let stmt = PreparedStatement(cass_session_prepare(session, query))
        return stmt
    }
    public func execute(batch: Batch) -> Future {
        return Future(cass_session_execute_batch(session, batch.batch))
    }
    public var schemaMeta: SchemaMeta { get {return SchemaMeta(cass_session_get_schema_meta(session))} }
    /*public func getSchemaMeta() -> SchemaMeta {
        return SchemaMeta(cass_session_get_schema_meta(session))
    }*/
    public func close() -> Future {
        return Future(cass_session_close(session))
    }
}

