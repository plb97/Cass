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
        print("init Batch \(batch) \(type(of: batch))")
        super.init()
    }
    deinit {
        print("deinit Batch \(batch) \(type(of: batch))")
        cass_batch_free(batch)
    }
    public func addStatement(_ statement: Statement) -> Batch {
        print("Batch: add statement... \(statement.statement) \(type(of: statement.statement))")
        statements.append(statement)
        cass_batch_add_statement(batch, statement.statement)
        print("Batch: ...add statement")
        return self
    }
    public func setConsistencyAny() -> Batch {
        error = message(cass_batch_set_consistency(batch, CASS_CONSISTENCY_ANY))
        return self
    }
    public func setConsistencyOne() -> Batch {
        error = message(cass_batch_set_consistency(batch, CASS_CONSISTENCY_ONE))
        return self
    }
    public func setConsistencyTwo() -> Batch {
        error = message(cass_batch_set_consistency(batch, CASS_CONSISTENCY_TWO))
        return self
    }
    public func setConsistencyThree() -> Batch {
        error = message(cass_batch_set_consistency(batch, CASS_CONSISTENCY_THREE))
        return self
    }
    public func setConsistencyQuorum() -> Batch {
        error = message(cass_batch_set_consistency(batch, CASS_CONSISTENCY_QUORUM))
        return self
    }
    public func setConsistencyAll() -> Batch {
        error = message(cass_batch_set_consistency(batch, CASS_CONSISTENCY_ALL))
        return self
    }
    public func setConsistencyLocalQuorum() -> Batch {
        error = message(cass_batch_set_consistency(batch, CASS_CONSISTENCY_LOCAL_QUORUM))
        return self
    }
    public func setConsistencyEachQuorum() -> Batch {
        error = message(cass_batch_set_consistency(batch, CASS_CONSISTENCY_EACH_QUORUM))
        return self
    }
    public func setConsistencyLocalOne() -> Batch {
        error = message(cass_batch_set_consistency(batch, CASS_CONSISTENCY_LOCAL_ONE))
        return self
    }
    public func setConsistencySerial() -> Batch {
        error = message(cass_batch_set_serial_consistency(batch, CASS_CONSISTENCY_SERIAL))
        return self
    }
    public func setConsistencyLocalSerial() -> Batch {
        error = message(cass_batch_set_serial_consistency(batch, CASS_CONSISTENCY_LOCAL_SERIAL))
        return self
    }
    public func setTimestamp(_ date: Date) -> Batch {
        error = message(cass_batch_set_timestamp(batch, date2Timestamp(date: date)))
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

