# frozen_string_literal: true

require "socket"

require_relative "client"

module Moleculer
  module Registry
    ##
    # Node class
    class Node
      # @return [Array<String>] IP addresses of node
      attr_reader :ip_list

      # @return [String] the hostname of the node
      attr_reader :hostname

      # @return [Moleculer::Registry::Client] node client data
      attr_reader :client

      # @return [Integer] the sequence of the node
      attr_reader :seq

      # @return [String] the node id
      attr_reader :id

      # @return [Array<Moleculer::Service::Base>] a list of the services
      # attached to the node
      attr_reader :services

      # @return [Time] the last time a heartbeat was received
      attr_reader :last_heartbeat_time

      ##
      # Creates an instance of Node from a provided schema
      #
      # @param [Hash] an info packet
      #
      # @return [Moleculer::Registry::Node] the remote node
      def self.from_schema(packet)
        info     = packet.payload
        services = info[:services].map do |service|
          Service.from_schema(service)
        end
        new(**info.merge(
          id:       options[:sender],
          services: services,
        ))
      end

      def initialize(id:, hostname:, services: [], ip_list: [], client: {}, seq: 0, local: false)
        @id                  = id
        @available           = true
        @local               = local
        @last_heartbeat_time = Time.now
        @ip_list             = ip_list
        @hostname            = hostname
        @seq                 = seq
        @client              = client
        @config              = {}

        @services = instantiate_services(services)
      end

      def local?
        @local
      end

      def actions
        services.values.collect(&:actions).reduce({}, :merge)
      end

      def events
        services.values.collect(&:events).reduce({}, :merge)
      end

      def beat
        @last_heartbeat_time = Time.now
        @available           = true
        @offline_since       = nil
      end

      def disconnected(_unexpected)
        if available?
          @offline_since = Time.now
          @seq          += 1
        end

        @available = false
      end

      def available?
        @available
      end

      ##
      # @return [::Hash] the node schema
      def schema
        {
          ip_list:  ip_list,
          hostname: hostname,
          client:   client,
          seq:      seq,
          port:     port,
          services: services.values.map(&:schema),
        }
      end

      private

      def instantiate_services(services)
        Concurrent::Hash[(services || []).map { |s| [s.service_name, s.new(@broker, self)] }]
      end
    end
  end
end
