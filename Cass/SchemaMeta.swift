//
//  SchemaMeta.swift
//  Cass
//
//  Created by Philippe on 22/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public class SchemaMeta {
    public struct KeyspaceMetaSubscript {
        let schemaMeta: SchemaMeta
        init(_ schemaMeta: SchemaMeta) {
            self.schemaMeta = schemaMeta
        }
        public typealias Element = KeyspaceMeta?
        public subscript(keyspace: String) -> Element {
            get {
                let km = cass_schema_meta_keyspace_by_name(schemaMeta.schema_meta, keyspace)
                return KeyspaceMeta(km)
            }
        }
    }
    let schema_meta: OpaquePointer
    lazy public var keyspaceMeta: KeyspaceMetaSubscript = KeyspaceMetaSubscript(self)
    init(_ schema_meta: OpaquePointer) {
        self.schema_meta = schema_meta
    }
    deinit {
        cass_schema_meta_free(schema_meta)
    }
    public var snapshotVersion: UInt32 {
        return cass_schema_meta_snapshot_version(schema_meta)
    }
    public var version: Version {
        return Version(cass_schema_meta_version(schema_meta))
    }
    public func keyspaceMeta(keyspace: String) -> KeyspaceMeta? {
        return KeyspaceMeta(cass_schema_meta_keyspace_by_name(schema_meta, keyspace))
    }
}
