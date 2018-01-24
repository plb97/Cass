//
//  Batch.swift
//  Cass
//
//  Created by Philippe on 25/10/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

public
class Batch {
    var error_code_: Error?
    var statements = Array<Statement>() // garde une reference de chaque 'statement' ajoute durany toute la vie du 'batch'
    let batch: OpaquePointer
    public init(_ type: BatchType) {
        batch = cass_batch_new(type.cass)
    }
    deinit {
        cass_batch_free(batch)
    }
    @discardableResult
    public func check(checker: ((_ err: Error) -> Bool) = default_checker) -> Bool {
        if let error_code = error_code_ {
            return error_code.check(checker: checker)
        }
        return true
    }
    public func addStatement(_ statement: Statement) -> Batch {
        statements.append(statement)
        cass_batch_add_statement(batch, statement.statement)
        return self
    }
    public func setConsistency(_ consistency: Consistency) -> Batch {
        error_code_ = Error(cass_batch_set_consistency(batch, consistency.cass))
        return self
    }
    public func setSerialConsistency(_ consistency: SerialConsistency) -> Batch {
        error_code_ = Error(cass_batch_set_serial_consistency(batch, consistency.cass))
        return self
    }
    public func setTimestamp(_ date: Date) -> Batch {
        error_code_ = Error(cass_batch_set_timestamp(batch, date.timestamp))
        return self
    }
    public func setRequestTimeout(_ timeout_ms: UInt64) -> Batch {
        error_code_ = Error(cass_batch_set_request_timeout(batch, timeout_ms))
        return self
    }
    public func setIsIdempotent(_ is_idempotent: Bool) -> Batch {
        error_code_ = Error(cass_batch_set_is_idempotent(batch, is_idempotent ? cass_true : cass_false ))
        return self
    }
    public func setRetryPolicy(_ retry_policy: RetryPolicy) -> Batch {
        error_code_ = Error(cass_batch_set_retry_policy(batch, retry_policy.policy))
        return self
    }
}

