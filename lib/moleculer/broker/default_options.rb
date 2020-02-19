# frozen_string_literal: true

require_relative "../utils/utils"
require_relative "../strategies"

module Moleculer
  module Broker
    ##
    # Encapsulate all of the brokers configurations
    module DefaultOptions
      attr_reader :options, :node_id, :services, :namespace

      ##
      # Default broker options
      DEFAULT_OPTIONS = {
        namespace:            "",
        request_timeout:      0 * 1000,
        log_level:            ENV["MOLECULER_LOG_LEVEL"] || "debug",
        log_file:             STDOUT,
        node_id:              Utils.get_node_id,

        retry_policy:         {
          enabled:  false,
          retries:  5,
          delay:    100,
          maxDelay: 1000,
          factor:   2,
          # check: err => err && !!err.retryable
        },
        serializer:           "Json",
        transporter:          {
          url: "redis://localhost",
        },

        max_call_level:       0,
        heartbeat_interval:   5,
        heartbeat_timeout:    15,

        tracking:             {
          enabled:          false,
          shutdown_timeout: 5000,
        },

        disable_balancer:     false,

        registry:             {
          strategy:     Strategies::Random,
          prefer_local: true,
        },

        circuit_breaker:      {
          enabled:           false,
          threshold:         0.5,
          window_time:       60,
          min_request_count: 20,
          half_open_time:    10 * 1000,
          # check: err => err && err.code >= 500
        },

        bulkhead:             {
          enabled:        false,
          concurrency:    10,
          max_queue_size: 100,
        },

        transit:              {
          # maxQueueSize: 50 * 1000, // 50k ~ 400MB,
          packet_log_filter:     [],
          disable_reconnect:     false,
          disable_version_check: false,
        },

        validation:           true,
        metrics:              false,
        metricsRate:          1,
        internalServices:     true,
        internal_middlewares: true,
        hot_reload:           false,

      }.freeze

      ##
      # @param options [::Hash] moleculer options
      def initialize(options = {})
        @options   = DEFAULT_OPTIONS.merge(options)
        @node_id   = @options[:node_id]
        @services  = @options[:services]
        @namespace = @options[:namespace]
        super
      end

    end



  end
end
