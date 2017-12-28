//
//  RetryPolicy.swift
//  Cass
//
//  Created by Philippe on 24/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

//import Foundation

public
class RetryPolicy {
    let policy: OpaquePointer!
    init(_ policy: OpaquePointer? = cass_retry_policy_default_new()) {
        self.policy = policy
    }
    deinit {
        cass_retry_policy_free(policy)
    }
}
public
class RetryrPolicyDowngradingDefault: RetryPolicy {
    init() {
        super.init(cass_retry_policy_default_new())
    }
}
public
class RetryrPolicyDowngradingConsistency: RetryPolicy {
    init() {
        super.init(cass_retry_policy_downgrading_consistency_new())
    }
}
public
class RetryrPolicyFallthroughConsistency: RetryPolicy {
    init() {
        super.init(cass_retry_policy_fallthrough_new())
    }
}
public
class RetryrPolicyLoggingConsistency: RetryPolicy {
    init(_ child_retry_policy: RetryPolicy) {
        super.init(cass_retry_policy_logging_new(child_retry_policy.policy))
    }
}
