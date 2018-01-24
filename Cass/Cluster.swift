//
//  Cluster.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

public
class Cluster {
    let cluster: OpaquePointer
    var error_code_: Error?
    public init() {
        cluster = cass_cluster_new()
    }
    deinit {
        cass_cluster_free(cluster)
    }
    public func setContactPoints(_ contact_points: String) -> Cluster {
        error_code_ = Error(cass_cluster_set_contact_points(cluster, contact_points))
        return self
    }
    public func setPort(_ port: Int = 9042) -> Cluster {
        error_code_ = Error(cass_cluster_set_port (cluster, Int32(port)))
        return self
    }
    func setSsl(_ ssl: OpaquePointer?) -> Cluster {
         cass_cluster_set_ssl(cluster, ssl)
         return self
    }
    public func setAuthenticatorCallbacks(_ authenticatorCallbacks: AuthenticatorCallbacks) -> Cluster {
        let data = UnsafeMutablePointer<AuthenticatorCallbacks>.allocate(capacity: 1)
        data.initialize(to: authenticatorCallbacks)
        var exchange_callbacks = default_exchange_callbacks
        if nil == error_code_ {
            error_code_ = Error(cass_cluster_set_authenticator_callbacks(cluster, &exchange_callbacks, default_data_cleanup_callback, data))
        }
        return self
    }
    public func setProtocolVersion(_ protocol_version: ProtocolVersion = .v4) -> Cluster {
        if nil == error_code_ {
            error_code_ = Error(cass_cluster_set_protocol_version(cluster, Int32(protocol_version.cass.rawValue)))
        }
        return self
    }
    public func setNumThreadsIo(_ num_threads: UInt = 1) -> Cluster {
        if nil == error_code_ {
            error_code_ = Error(cass_cluster_set_num_threads_io(cluster, UInt32(num_threads)))
        }
        return self
    }
    public func setQueueSizeIo(_ queue_size: UInt = 8192) {
        if nil == error_code_ {
            error_code_ = Error(cass_cluster_set_queue_size_io(cluster, UInt32(queue_size)))
        }
    }
    public func setQueueSizeEvent(_ queue_size: UInt = 8192) -> Cluster {
        if nil == error_code_ {
            error_code_ = Error(cass_cluster_set_queue_size_event(cluster, UInt32(queue_size)))
        }
        return self
    }
    public func setCoreConnectionsPerHost(_ num_connections: UInt = 1) -> Cluster {
        if nil == error_code_ {
            error_code_ = Error(cass_cluster_set_core_connections_per_host(cluster, UInt32(num_connections)))
        }
        return self
    }
    public func setMaxConnectionsPerHost(_ num_connections: UInt = 2) -> Cluster {
        if nil == error_code_ {
            error_code_ = Error(cass_cluster_set_max_connections_per_host(cluster, UInt32(num_connections)))
        }
        return self
    }
    public func setReconnectWaitTime(_ wait_time: UInt = 2000) -> Cluster {
        cass_cluster_set_reconnect_wait_time(cluster, UInt32(wait_time))
        return self
    }
    public func setMaxConcurrentCreation(_ num_connections: UInt = 1) -> Cluster {
        if nil == error_code_ {
            error_code_ = Error(cass_cluster_set_max_concurrent_creation(cluster, UInt32(num_connections)))
        }
        return self
    }
    public func setMaxConcurrentRequestsThreshold(_ num_requests: UInt = 100) -> Cluster {
        if nil == error_code_ {
            error_code_ = Error(cass_cluster_set_max_concurrent_requests_threshold(cluster, UInt32(num_requests)))
        }
        return self
    }
    public func setMaxRequestsPerFlush(_ num_requests: UInt = 128) -> Cluster {
        error_code_ = Error(cass_cluster_set_max_requests_per_flush(cluster, UInt32(num_requests)))
        return self
    }
//    public func setWriteBytesHighWaterMark(_ num_bytes: UInt = 64 * 1024) -> Cluster {
//        if nil == error_code_ {
//            error_code_ = Error(cass_cluster_set_write_bytes_high_water_mark(cluster, UInt32(num_bytes)))
//        }
//        return self
//    }
//    public func setWriteBytesLowWaterMark(_ num_bytes: UInt = 32 * 1024) -> Cluster {
//        if nil == error_code_ {
//            error_code_ = Error(cass_cluster_set_write_bytes_low_water_mark(cluster, UInt32(num_bytes)))
//        }
//        return self
//    }
//    public func setPendingRequestsHighWaterMark(_ num_requests: UInt = 256) -> Cluster {
//        if nil == error_code_ {
//            error_code_ = Error(cass_cluster_set_pending_requests_high_water_mark(cluster, UInt32(num_requests)))
//        }
//        return self
//    }
//    public func setPendingRequestsLowWaterMark(_ num_requests: UInt = 128) -> Cluster {
//        if nil == error_code_ {
//            error_code_ = Error(cass_cluster_set_pending_requests_low_water_mark(cluster, UInt32(num_requests)))
//        }
//        return self
//    }
    public func setConnectTimeout(_ timeout_ms: UInt = 5000) -> Cluster {
        cass_cluster_set_connect_timeout(cluster, UInt32(timeout_ms))
        return self
    }
    public func setRequestTimeout(_ timeout_ms: UInt = 12000) -> Cluster {
        cass_cluster_set_request_timeout(cluster, UInt32(timeout_ms))
        return self
    }
    public func setResolveTimeout(_ timeout_ms: UInt = 2000) -> Cluster {
        cass_cluster_set_resolve_timeout(cluster, UInt32(timeout_ms))
        return self
    }
    public func setCredentials(username: String = "cassandra", password: String = "cassandra") -> Cluster {
        cass_cluster_set_credentials(cluster, username, password)
        return self
    }
    public func setLoadBalanceRoundRobin() -> Cluster {
        cass_cluster_set_load_balance_round_robin(cluster)
        return self
    }
    public func setLoadBalanceDcAware(local_dc: String = "local", used_hosts_per_remote_dc: UInt = 1, allow_remote_dcs_for_local_cl: Bool = false) -> Cluster {
        if nil == error_code_ {
            error_code_ = Error(cass_cluster_set_load_balance_dc_aware(cluster, local_dc, UInt32(used_hosts_per_remote_dc), allow_remote_dcs_for_local_cl ? cass_true : cass_false))
        }
        return self
    }
    public func setTokenAwareRouting(_ enabled: Bool = true) -> Cluster {
        cass_cluster_set_token_aware_routing(cluster, enabled ? cass_true : cass_false)
        return self
    }
    public func setLatencyAwareRouting(_ enabled: Bool = false) -> Cluster {
        cass_cluster_set_latency_aware_routing(cluster, enabled ? cass_true : cass_false)
        return self
    }
    public func setLatencyAwareRoutingSetting(exclusion_threshold: Double = 2.0, scale_ms: UInt64 = 100, retry_period_ms: UInt64 = 10_000, update_rate_ms: UInt64 = 100, min_measured: UInt64 = 50) -> Cluster {
        cass_cluster_set_latency_aware_routing_settings(cluster, exclusion_threshold, scale_ms, retry_period_ms, update_rate_ms, min_measured)
        return self
    }
    public func setWhitelistFiltering(_ hosts: String) -> Cluster {
        cass_cluster_set_whitelist_filtering(cluster, hosts)
        return self
    }
    public func setBlacklistFiltering(_ hosts: String) -> Cluster {
        cass_cluster_set_blacklist_filtering(cluster, hosts)
        return self
    }
    public func setWhitelistDcFiltering(_ dcs: String) -> Cluster {
        cass_cluster_set_whitelist_dc_filtering ( cluster, dcs )
        return self
    }
    public func setBlacklistDcFiltering(_ dcs: String) -> Cluster {
        cass_cluster_set_blacklist_dc_filtering ( cluster, dcs )
        return self
    }
    public func setTcpNodelay(_ enabled: Bool = true) -> Cluster {
        cass_cluster_set_tcp_nodelay(cluster, enabled ? cass_true : cass_false)
        return self
    }
    public func setTcpKeepalive(enabled: Bool = false, delay_secs: UInt = 0) -> Cluster {
        cass_cluster_set_tcp_keepalive(cluster, enabled ? cass_true : cass_false, UInt32(delay_secs))
        return self
    }
    public func setTimestampGenServerSide() -> Cluster {
        cass_cluster_set_timestamp_gen(cluster, cass_timestamp_gen_server_side_new())
        return self
    }
    public func setTimestampGenMonotonic() -> Cluster {
        cass_cluster_set_timestamp_gen(cluster, cass_timestamp_gen_monotonic_new())
        return self
    }
    public func setConnectionHeartbeatInterval(_ interval_secs: Int = 30) -> Cluster {
        cass_cluster_set_connection_heartbeat_interval(cluster, UInt32(interval_secs))
        return self
    }
    public func setIdleTimeout(_ timeout_secs: Int = 60) -> Cluster {
        cass_cluster_set_connection_idle_timeout(cluster, UInt32(timeout_secs))
        return self
    }
    public func setRetryPolicy(retry_policy: OpaquePointer! = cass_retry_policy_default_new()) -> Cluster {
        cass_cluster_set_retry_policy(cluster, retry_policy)
        return self
    }
    public func setUseSchema(_ enabled: Bool = true) -> Cluster {
        cass_cluster_set_use_schema(cluster, enabled ? cass_true : cass_false)
        return self
    }
    public func setUseHostnameResolution(_ enabled: Bool = false) -> Cluster {
        if nil == error_code_ {
            error_code_ = Error(cass_cluster_set_use_hostname_resolution(cluster, enabled ? cass_true : cass_false))
        }
        return self
    }
    public func setRandomizedContactPoint(_ enabled: Bool = true) -> Cluster {
        if nil == error_code_ {
            error_code_ = Error(cass_cluster_set_use_randomized_contact_points(cluster, enabled ? cass_true : cass_false))
        }
        return self
    }
    public func setConstantSpeculativeExecutionPolicy(constant_delay_ms: Int64, max_speculative_executions: Int)
        -> Cluster {
            if nil == error_code_ {
                error_code_ = Error(cass_cluster_set_constant_speculative_execution_policy(cluster, constant_delay_ms, Int32(max_speculative_executions)))
            }
            return self
    }
    public func setNoSpeculativeExecutionPolicy() -> Cluster {
        if nil == error_code_ {
            error_code_ = Error(cass_cluster_set_no_speculative_execution_policy(cluster))
        }
        return self
    }
}

