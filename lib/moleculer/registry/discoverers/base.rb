# frozen_string_literal: true

require "timers"

module Moleculer
  class Registry
    module Discoverers
      ##
      # Base class for discoverers
      class Base
        ##
        # @param [Moleculer::Registry] registry The registry instance
        # @param [Integer] heartbeat_interval The interval in milliseconds between heartbeats
        # @param [Integer] heartbeat_timeout The timeout in milliseconds for a heartbeat
        # @param [Boolean] disable_heartbeat_checks Disables the heartbeat checks, Default: false
        # @param [Boolean] disable_offline_node_removing Disables the removing of offline nodes, Default: false
        # @param [Integer] clean_offline_notes_timeout The timeout in milliseconds for cleaning offline nodes
        # rubocop:disable Metrics/ParameterLists
        def initialize(
          registry:,
          heartbeat_interval: 5,
          heartbeat_timeout: 15,
          disable_heartbeat_checks: false,
          disable_offline_node_removing: false,
          clean_offline_notes_timeout: 600
        )
          @heartbeat_interval = heartbeat_interval
          @heartbeat_timeout = heartbeat_timeout
          @disable_heartbeat_checks = disable_heartbeat_checks
          @disable_offline_node_removing = disable_offline_node_removing
          @clean_offline_notes_timeout = clean_offline_notes_timeout
          @local_node = nil
          @heartbeat_timers = Timers::Group.new
          @registry = registry
        end
        # rubocop:enable Metrics/ParameterLists

        ##
        # @return [Logger] The logger instance
        def logger
          @registry.logger
        end
      end

      ##
      # Discover a new or old node by its ID
      # @param [String] id The node ID
      # @return [Moleculer::Registry::Node] The node
      def discover_node(id)
        raise NotImplementedError
      end

      ##
      # Discover all nodes (after connected)
      # @return [Array<Moleculer::Registry::Node>] The list of nodes
      def discover_all_nodes
        raise NotImplementedError
      end

      ##
      # Local service registry has been changed. Notify the nodes
      # @param [String] id The node ID
      def send_local_node_info(id)
        raise NotImplementedError
      end

      private

      ##
      # Start the heartbeat timers
      def start_heartbeat_timers
        stop_heartbeat_timers
        return unless @heartbeat_interval.positive?

        @heartbeat_timers.every(@heartbeat_interval) do
          beat
        end

        @heartbeat_timers.after(@heartbeat_timeout) do
          check_remote_nodes
        end

        @heartbeat_timers.after(@clean_offline_notes_timeout) do
          check_offline_nodes
        end
      end

      ##
      # Stop the heartbeat timers
      def stop_heartbeat_timers
        @heartbeat_timers.cancel
      end

      ##
      # Disable the heartbeat
      def disable_heartbeat
        @heartbeat_interval = 0
        stop_heartbeat_timers
      end

      def beat; end

      def check_remote_nodes; end

      def check_offline_nodes; end
    end
  end
end
