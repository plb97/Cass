//
//  Batch.swift
//  Cass
//
//  Created by Philippe on 25/10/2017.
//  Copyright © 2017 PLB. All rights reserved.
//
import Foundation

public
class Batch: Error {
    let batch: OpaquePointer!
    init(_ type: CassBatchType) {
        batch = cass_batch_new(type)
        super.init()
    }
    deinit {
        cass_batch_free(batch)
    }
    public func setConsistencyAny() -> () {
        error = message(cass_batch_set_consistency(batch, CASS_CONSISTENCY_ANY))
    }
    public func setConsistencyOne() -> () {
        error = message(cass_batch_set_consistency(batch, CASS_CONSISTENCY_ONE))
    }
    public func setConsistencyTwo() -> () {
        error = message(cass_batch_set_consistency(batch, CASS_CONSISTENCY_TWO))
    }
    public func setConsistencyThree() -> () {
        error = message(cass_batch_set_consistency(batch, CASS_CONSISTENCY_THREE))
    }
    public func setConsistencyQuorum() -> () {
        error = message(cass_batch_set_consistency(batch, CASS_CONSISTENCY_QUORUM))
    }
    public func setConsistencyAll() -> () {
        error = message(cass_batch_set_consistency(batch, CASS_CONSISTENCY_ALL))
    }
    public func setConsistencyLocalQuorum() -> () {
        error = message(cass_batch_set_consistency(batch, CASS_CONSISTENCY_LOCAL_QUORUM))
    }
    public func setConsistencyEachQuorum() -> () {
        error = message(cass_batch_set_consistency(batch, CASS_CONSISTENCY_EACH_QUORUM))
    }
    public func setConsistencyLocalOne() -> () {
        error = message(cass_batch_set_consistency(batch, CASS_CONSISTENCY_LOCAL_ONE))
    }
    public func setConsistencySerial() -> () {
        error = message(cass_batch_set_serial_consistency(batch, CASS_CONSISTENCY_SERIAL))
    }
    public func setConsistencyLocalSerial() -> () {
        error = message(cass_batch_set_serial_consistency(batch, CASS_CONSISTENCY_LOCAL_SERIAL))
    }
    public func setTimestamp(_ date: Date) -> () {
        error = message(cass_batch_set_timestamp(batch, date2Timestamp(date: date)))
    }
    public func setRequestTimeout(_ timeout_ms: UInt64) -> () {
        error = message(cass_batch_set_request_timeout(batch, timeout_ms))
    }
    public func setIsIdempotent(_ is_idempotent: Bool) -> () {
        error = message(cass_batch_set_is_idempotent(batch, is_idempotent ? cass_true : cass_false ))
    }
    public func setRetryPolicy(_ retry_policy: RetryPolicy) -> () {
        error = message(cass_batch_set_retry_policy(batch, retry_policy.policy))
    }

    public func addStatement(_ statement: SimpleStatement) {
        if let stmt = statement.stmt() {
            defer {
                cass_statement_free(stmt)
            }
            cass_batch_add_statement(batch, stmt)
        }
    }
    public func addStatement(prepared: PreparedStatement,_ lst: [Any?]) {
        if let statement = prepared.stmt(lst) {
            defer {
                cass_statement_free(statement)
            }
            cass_batch_add_statement(batch, statement)
        }
    }
    public func addStatement(prepared: PreparedStatement, map: [String: Any?]) {
        if let statement = prepared.stmt(map: map) {
            defer {
                cass_statement_free(statement)
            }
            cass_batch_add_statement(batch, statement)
        }
    }
}

public
class BatchLogged: Batch {
    public init() {
        super.init(CASS_BATCH_TYPE_LOGGED)
    }
}
public
class BatchUnLogged: Batch {
    public init() {
        super.init(CASS_BATCH_TYPE_UNLOGGED)
    }
}
public
class BatchCounter: Batch {
    public init() {
        super.init(CASS_BATCH_TYPE_COUNTER)
    }
}

