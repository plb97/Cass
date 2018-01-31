//
//  Metrics.swift
//  Cass
//
//  Created by Philippe on 31/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

public struct Metrics {
    public struct Requests {
        public let min: UInt64
        public let max: UInt64
        public let mean: UInt64
        public let stddev: UInt64
        public let median: UInt64
        public let percentile_75th: UInt64
        public let percentile_95th: UInt64
        public let percentile_98th: UInt64
        public let percentile_99th: UInt64
        public let percentile_999th: UInt64
        public let mean_rate: Double
        public let one_minute_rate: Double
        public let five_minute_rate: Double
        public let fifteen_minute_rate: Double
        init(min: UInt64, max: UInt64, mean: UInt64, stddev: UInt64, median: UInt64
            , percentile_75th: UInt64, percentile_95th: UInt64, percentile_98th: UInt64, percentile_99th: UInt64, percentile_999th: UInt64
            , mean_rate: Double, one_minute_rate: Double, five_minute_rate: Double, fifteen_minute_rate: Double
            ) {
            self.min = min
            self.max = max
            self.mean = mean
            self.stddev = stddev
            self.median = median
            self.percentile_75th = percentile_75th
            self.percentile_95th = percentile_95th
            self.percentile_98th = percentile_98th
            self.percentile_99th = percentile_99th
            self.percentile_999th = percentile_999th
            self.mean_rate = mean_rate
            self.one_minute_rate = one_minute_rate
            self.five_minute_rate = five_minute_rate
            self.fifteen_minute_rate = fifteen_minute_rate
        }
    }
    public struct Stats {
        public let total_connections: UInt64
        public let available_connections: UInt64
        public let exceeded_pending_requests_water_mark: UInt64
        public let exceeded_write_bytes_water_mark: UInt64
        init(total_connections: UInt64, available_connections: UInt64, exceeded_pending_requests_water_mark: UInt64, exceeded_write_bytes_water_mark: UInt64) {
            self.total_connections = total_connections
            self.available_connections = available_connections
            self.exceeded_pending_requests_water_mark = exceeded_pending_requests_water_mark
            self.exceeded_write_bytes_water_mark = exceeded_write_bytes_water_mark
        }
    }
    public struct Errors {
        public let connection_timeouts: UInt64
        public let pending_request_timeouts: UInt64
        public let request_timeouts: UInt64
        init(connection_timeouts: UInt64, pending_request_timeouts: UInt64, request_timeouts: UInt64) {
            self.connection_timeouts = connection_timeouts
            self.pending_request_timeouts = pending_request_timeouts
            self.request_timeouts = request_timeouts
        }
    }
    public let requests: Requests
    public let stats: Stats
    public let errors: Errors
    init(_ metrics: CassMetrics) {
        requests = Requests(min: metrics.requests.min
            , max: metrics.requests.max
            , mean: metrics.requests.mean
            , stddev: metrics.requests.stddev
            , median: metrics.requests.median
            , percentile_75th: metrics.requests.percentile_75th
            , percentile_95th: metrics.requests.percentile_95th
            , percentile_98th: metrics.requests.percentile_98th
            , percentile_99th: metrics.requests.percentile_99th
            , percentile_999th: metrics.requests.percentile_999th
            , mean_rate: metrics.requests.mean_rate
            , one_minute_rate: metrics.requests.one_minute_rate
            , five_minute_rate: metrics.requests.five_minute_rate
            , fifteen_minute_rate: metrics.requests.fifteen_minute_rate
        )
        stats = Stats(total_connections: metrics.stats.total_connections
            , available_connections: metrics.stats.available_connections
            , exceeded_pending_requests_water_mark: metrics.stats.exceeded_pending_requests_water_mark
            , exceeded_write_bytes_water_mark: metrics.stats.exceeded_write_bytes_water_mark
        )
        errors = Errors(connection_timeouts: metrics.errors.connection_timeouts
            , pending_request_timeouts: metrics.errors.pending_request_timeouts
            , request_timeouts: metrics.errors.request_timeouts)
    }
}
