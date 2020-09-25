# frozen_string_literal: true

module Moleculer
  ##
  # Node class
  class Node
    attr_reader :local,
      :ip_list,
      :hostname,
      :client,
      :seq,
      :id,
      :services,
      :last_heartbeat_time,
      def self.from_info_packet(broker, packet)
        options = packet.payload
        options.merge!(
          id:       options[:sender],
          services: options[:services].map { |service| Moleculer::Service.from_schema(service) },
        )
        new(broker, options)
      end

    def initialize(broker, id:, hostname:, services: [], ip_list: [], client: {}, seq: 0, local: false)
      @broker              = broker
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
