//
//  Cluster.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

public class Cluster {
    let cluster: OpaquePointer
    var error_code: Error
    public init() {
        cluster = cass_cluster_new()
        error_code = Error()
    }
    deinit {
        cass_cluster_free(cluster)
    }
    @discardableResult
    public func setContactPoints(_ contact_points: String) -> Cluster {
        if .ok == error_code {
            error_code = Error(cass_cluster_set_contact_points(cluster, contact_points))
        }
        return self
    }
    @discardableResult
    public func setPort(_ port: Int = 9042) -> Cluster {
        if .ok == error_code {
            error_code = Error(cass_cluster_set_port (cluster, Int32(port)))
        }
        return self
    }
    @discardableResult
    func setSsl(_ ssl: OpaquePointer?) -> Cluster {
         cass_cluster_set_ssl(cluster, ssl)
         return self
    }
    @discardableResult
    public func setAuthenticatorCallbacks(_ authenticatorCallbacks: AuthenticatorCallbacks) -> Cluster {
        let data = allocPointer(authenticatorCallbacks)
        if .ok == error_code {
            error_code = Error(cass_cluster_set_authenticator_callbacks(cluster, &default_exchange_callbacks, default_data_cleanup_callback, data))
        }
        return self
    }
    @discardableResult
    public func setProtocolVersion(_ protocol_version: ProtocolVersion = .v4) -> Cluster {
        if .ok == error_code {
            error_code = Error(cass_cluster_set_protocol_version(cluster, Int32(protocol_version.cass.rawValue)))
        }
        return self
    }
    @discardableResult
    public func setNumThreadsIo(_ num_threads: Int = 1) -> Cluster {
        if .ok == error_code {
            error_code = Error(cass_cluster_set_num_threads_io(cluster, UInt32(num_threads)))
        }
        return self
    }
    @discardableResult
    public func setQueueSizeIo(_ queue_size: Int = 8192) -> Cluster {
        if .ok == error_code {
            error_code = Error(cass_cluster_set_queue_size_io(cluster, UInt32(queue_size)))
        }
        return self
    }
    @discardableResult
    public func setQueueSizeEvent(_ queue_size: Int = 8192) -> Cluster {
        if .ok == error_code {
            error_code = Error(cass_cluster_set_queue_size_event(cluster, UInt32(queue_size)))
        }
        return self
    }
    @discardableResult
    public func setCoreConnectionsPerHost(_ num_connections: Int = 1) -> Cluster {
        if .ok == error_code {
            error_code = Error(cass_cluster_set_core_connections_per_host(cluster, UInt32(num_connections)))
        }
        return self
    }
    @discardableResult
    public func setMaxConnectionsPerHost(_ num_connections: Int = 2) -> Cluster {
        if .ok == error_code {
            error_code = Error(cass_cluster_set_max_connections_per_host(cluster, UInt32(num_connections)))
        }
        return self
    }
    @discardableResult
    public func setReconnectWaitTime(_ wait_time: Int = 2000) -> Cluster {
        cass_cluster_set_reconnect_wait_time(cluster, UInt32(wait_time))
        return self
    }
    @discardableResult
    public func setMaxConcurrentCreation(_ num_connections: Int = 1) -> Cluster {
        if .ok == error_code {
            error_code = Error(cass_cluster_set_max_concurrent_creation(cluster, UInt32(num_connections)))
        }
        return self
    }
    @discardableResult
    public func setMaxConcurrentRequestsThreshold(_ num_requests: Int = 100) -> Cluster {
        if .ok == error_code {
            error_code = Error(cass_cluster_set_max_concurrent_requests_threshold(cluster, UInt32(num_requests)))
        }
        return self
    }
    @discardableResult
    public func setMaxRequestsPerFlush(_ num_requests: Int = 128) -> Cluster {
        error_code = Error(cass_cluster_set_max_requests_per_flush(cluster, UInt32(num_requests)))
        return self
    }
//    @discardableResult
//    public func setWriteBytesHighWaterMark(_ num_bytes: Int = 64 * 1024) -> Cluster {
//        if .ok == error_code {
//            error_code = Error(cass_cluster_set_write_bytes_high_water_mark(cluster, UInt32(num_bytes)))
//        }
//        return self
//    }
//    @discardableResult
//    public func setWriteBytesLowWaterMark(_ num_bytes: Int = 32 * 1024) -> Cluster {
//        if .ok == error_code {
//            error_code = Error(cass_cluster_set_write_bytes_low_water_mark(cluster, UInt32(num_bytes)))
//        }
//        return self
//    }
//    @discardableResult
//    public func setPendingRequestsHighWaterMark(_ num_requests: Int = 256) -> Cluster {
//        if .ok == error_code {
//            error_code = Error(cass_cluster_set_pending_requests_high_water_mark(cluster, UInt32(num_requests)))
//        }
//        return self
//    }
//    @discardableResult
//    public func setPendingRequestsLowWaterMark(_ num_requests: Int = 128) -> Cluster {
//        if .ok == error_code {
//            error_code = Error(cass_cluster_set_pending_requests_low_water_mark(cluster, UInt32(num_requests)))
//        }
//        return self
//    }
    @discardableResult
    public func setConnectTimeout(_ timeout_ms: Int = 5000) -> Cluster {
        cass_cluster_set_connect_timeout(cluster, UInt32(timeout_ms))
        return self
    }
    @discardableResult
    public func setRequestTimeout(_ timeout_ms: Int = 12000) -> Cluster {
        cass_cluster_set_request_timeout(cluster, UInt32(timeout_ms))
        return self
    }
    @discardableResult
    public func setResolveTimeout(_ timeout_ms: Int = 2000) -> Cluster {
        cass_cluster_set_resolve_timeout(cluster, UInt32(timeout_ms))
        return self
    }
    @discardableResult
    public func setCredentials(username: String = "cassandra", password: String = "cassandra") -> Cluster {
        cass_cluster_set_credentials(cluster, username, password)
        return self
    }
    @discardableResult
    public func setLoadBalanceRoundRobin() -> Cluster {
        cass_cluster_set_load_balance_round_robin(cluster)
        return self
    }
    @discardableResult
    public func setLoadBalanceDcAware(local_dc: String = "local", used_hosts_per_remote_dc: UInt = 1, allow_remote_dcs_for_local_cl: Bool = false) -> Cluster {
        if .ok == error_code {
            error_code = Error(cass_cluster_set_load_balance_dc_aware(cluster, local_dc, UInt32(used_hosts_per_remote_dc), allow_remote_dcs_for_local_cl ? cass_true : cass_false))
        }
        return self
    }
    @discardableResult
    public func setTokenAwareRouting(_ enabled: Bool = true) -> Cluster {
        cass_cluster_set_token_aware_routing(cluster, enabled ? cass_true : cass_false)
        return self
    }
    @discardableResult
    public func setLatencyAwareRouting(_ enabled: Bool = false) -> Cluster {
        cass_cluster_set_latency_aware_routing(cluster, enabled ? cass_true : cass_false)
        return self
    }
    @discardableResult
    public func setLatencyAwareRoutingSetting(exclusion_threshold: Double = 2.0, scale_ms: UInt64 = 100, retry_period_ms: UInt64 = 10_000, update_rate_ms: UInt64 = 100, min_measured: UInt64 = 50) -> Cluster {
        cass_cluster_set_latency_aware_routing_settings(cluster, exclusion_threshold, scale_ms, retry_period_ms, update_rate_ms, min_measured)
        return self
    }
    @discardableResult
    public func setWhitelistFiltering(_ hosts: String) -> Cluster {
        cass_cluster_set_whitelist_filtering(cluster, hosts)
        return self
    }
    @discardableResult
    public func setBlacklistFiltering(_ hosts: String) -> Cluster {
        cass_cluster_set_blacklist_filtering(cluster, hosts)
        return self
    }
    @discardableResult
    public func setWhitelistDcFiltering(_ dcs: String) -> Cluster {
        cass_cluster_set_whitelist_dc_filtering ( cluster, dcs )
        return self
    }
    @discardableResult
    public func setBlacklistDcFiltering(_ dcs: String) -> Cluster {
        cass_cluster_set_blacklist_dc_filtering ( cluster, dcs )
        return self
    }
    @discardableResult
    public func setTcpNodelay(_ enabled: Bool = true) -> Cluster {
        cass_cluster_set_tcp_nodelay(cluster, enabled ? cass_true : cass_false)
        return self
    }
    @discardableResult
    public func setTcpKeepalive(enabled: Bool = false, delay_secs: UInt = 0) -> Cluster {
        cass_cluster_set_tcp_keepalive(cluster, enabled ? cass_true : cass_false, UInt32(delay_secs))
        return self
    }
    @discardableResult
    public func setTimestampGenServerSide() -> Cluster {
        cass_cluster_set_timestamp_gen(cluster, cass_timestamp_gen_server_side_new())
        return self
    }
    @discardableResult
    public func setTimestampGenMonotonic() -> Cluster {
        cass_cluster_set_timestamp_gen(cluster, cass_timestamp_gen_monotonic_new())
        return self
    }
    @discardableResult
    public func setConnectionHeartbeatInterval(_ interval_secs: Int = 30) -> Cluster {
        cass_cluster_set_connection_heartbeat_interval(cluster, UInt32(interval_secs))
        return self
    }
    @discardableResult
    public func setIdleTimeout(_ timeout_secs: Int = 60) -> Cluster {
        cass_cluster_set_connection_idle_timeout(cluster, UInt32(timeout_secs))
        return self
    }
    @discardableResult
    public func setRetryPolicy(retry_policy: OpaquePointer! = cass_retry_policy_default_new()) -> Cluster {
        cass_cluster_set_retry_policy(cluster, retry_policy)
        return self
    }
    @discardableResult
    public func setUseSchema(_ enabled: Bool = true) -> Cluster {
        cass_cluster_set_use_schema(cluster, enabled ? cass_true : cass_false)
        return self
    }
    @discardableResult
    public func setUseHostnameResolution(_ enabled: Bool = false) -> Cluster {
        if .ok == error_code {
            error_code = Error(cass_cluster_set_use_hostname_resolution(cluster, enabled ? cass_true : cass_false))
        }
        return self
    }
    @discardableResult
    public func setRandomizedContactPoint(_ enabled: Bool = true) -> Cluster {
        if .ok == error_code {
            error_code = Error(cass_cluster_set_use_randomized_contact_points(cluster, enabled ? cass_true : cass_false))
        }
        return self
    }
    @discardableResult
    public func setConstantSpeculativeExecutionPolicy(constant_delay_ms: Int64, max_speculative_executions: Int)
        -> Cluster {
            if .ok == error_code {
                error_code = Error(cass_cluster_set_constant_speculative_execution_policy(cluster, constant_delay_ms, Int32(max_speculative_executions)))
            }
            return self
    }
    @discardableResult
    public func setNoSpeculativeExecutionPolicy() -> Cluster {
        if .ok == error_code {
            error_code = Error(cass_cluster_set_no_speculative_execution_policy(cluster))
        }
        return self
    }
}
