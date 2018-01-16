//
//  Batch.swift
//  Cass
//
//  Created by Philippe on 25/10/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

public
class Batch: Status {
    var statements = Array<Statement>() // garde une reference de chaque 'statement' ajoute durany toute la vie du 'batch'
    let batch: OpaquePointer
    init(_ type: CassBatchType) {
        batch = cass_batch_new(type)
        super.init()
    }
    deinit {
        cass_batch_free(batch)
    }
    public func addStatement(_ statement: Statement) -> Batch {
        statements.append(statement)
        cass_batch_add_statement(batch, statement.statement)
        return self
    }
    public func setConsistency(_ consistency: Consistency) -> Batch {
        error = message(cass_batch_set_consistency(batch, consistency.cass))
        return self
    }
    public func setSerialConsistency(_ consistency: SerialConsistency) -> Batch {
        error = message(cass_batch_set_serial_consistency(batch, consistency.cass))
        return self
    }
    public func setTimestamp(_ date: Date) -> Batch {
        error = message(cass_batch_set_timestamp(batch, date.timestamp))
        return self
    }
    public func setRequestTimeout(_ timeout_ms: UInt64) -> Batch {
        error = message(cass_batch_set_request_timeout(batch, timeout_ms))
        return self
    }
    public func setIsIdempotent(_ is_idempotent: Bool) -> Batch {
        error = message(cass_batch_set_is_idempotent(batch, is_idempotent ? cass_true : cass_false ))
        return self
    }
    public func setRetryPolicy(_ retry_policy: RetryPolicy) -> Batch {
        error = message(cass_batch_set_retry_policy(batch, retry_policy.policy))
        return self
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

