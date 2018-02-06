//
//  Batch.swift
//  Cass
//
//  Created by Philippe on 25/10/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public
class Batch {
    var error_code: Error
    var statements = Array<Statement>() // garde une reference de chaque 'statement' ajoute durany toute la vie du 'batch'
    var checker: (Error) -> Bool
    let batch: OpaquePointer
    public init(_ type: BatchType) {
        batch = cass_batch_new(type.cass)
        error_code = Error()
        self.checker = fatalChecker
    }
    deinit {
        cass_batch_free(batch)
    }
    @discardableResult
    public func setChecker(_ checker: @escaping Checker = fatalChecker) -> Self {
        self.checker = checker
        return self
    }
    @discardableResult
    public func check() -> Bool {
        return error_code.check(checker: checker)
    }
    public func addStatement(_ statement: Statement) -> Self {
        statements.append(statement)
        cass_batch_add_statement(batch, statement.statement)
        return self
    }
    public func setConsistency(_ consistency: Consistency) -> Self {
        error_code = Error(cass_batch_set_consistency(batch, consistency.cass))
        return self
    }
    public func setSerialConsistency(_ consistency: SerialConsistency) -> Self {
        error_code = Error(cass_batch_set_serial_consistency(batch, consistency.cass))
        return self
    }
    public func setTimestamp(_ date: Date) -> Self {
        error_code = Error(cass_batch_set_timestamp(batch, date.timestamp))
        return self
    }
    public func setRequestTimeout(_ timeout_ms: UInt64) -> Self {
        error_code = Error(cass_batch_set_request_timeout(batch, timeout_ms))
        return self
    }
    public func setIsIdempotent(_ is_idempotent: Bool) -> Self {
        error_code = Error(cass_batch_set_is_idempotent(batch, is_idempotent ? cass_true : cass_false ))
        return self
    }
    public func setRetryPolicy(_ retry_policy: RetryPolicy) -> Self {
        error_code = Error(cass_batch_set_retry_policy(batch, retry_policy.policy))
        return self
    }
}

