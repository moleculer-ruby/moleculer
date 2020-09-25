# frozen_string_literal: true

module Moleculer
  module Transporters
    ##
    # Base transporter class
    class Base
      include Logging

      def initialize(broker, options)
        @options                = options
        @connected              = false
        @built_in_load_balancer = false
        @broker                 = broker
      end

      ##
      # Overridden by child transporters
      #
      # @param [Boolean] reconnect true if the connection was a reconnect
      def after_connect(reconnect); end

      ##
      # @return [Boolean] returns if the transporter has a built in load balancer
      def built_in_load_balancer?
        @built_in_load_balancer
      end

      ##
      # Connect to the bus
      def connect
        raise NotImplementedError
      end

      ##
      # @return [Boolean] returns if the transporter is connected to it's bus
      def connected?
        @connected
      end

      ##
      # Disconnect from the bus
      def disconnect
        raise NotImplementedError
      end

      def publish(packet); end

      ##
      # Subscribe to a command
      #
      # @param [String] command command
      # @param [String] node_id node_id
      def subscribe(command, node_id)
        raise NotImplementedError
      end

      private

      attr_reader :options, :broker

      def send(topic, data, meta)
        raise NotImplementedError
      end

      def get_topic_name(command, node_id)
        "#{prefix}.#{command}#{node_id ? ".#{node_id}" : ''}"
      end

      def on_connected(reconnect = false)
        @connected = true
        after_connect(reconnect)
      end
    end
  end
end
