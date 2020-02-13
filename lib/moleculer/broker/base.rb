# frozen_string_literal: true

require_relative "default_options"
require_relative "local_event_bus"
require_relative "../serializers"
require_relative "../logger"
require_relative "../transit"

module Moleculer
  module Broker
    ##
    # Service Broker class
    class Base
      include DefaultOptions
      include Logger

      attr_reader :namespace, :serializer, :options, :transporter, :node_id, :local_bus, :services, :registry, :transit

      def initialize(options = {})
        @options     = DEFAULT_OPTIONS.merge(options)
        @started     = false
        @node_id     = @options[:node_id]
        @services    = @options[:services]
        @local_bus   = LocalEventBus.new
        @logger      = get_logger("BROKER")
        @serializer  = resolve_serializer(@options[:serializer])
        @registry    = Registry.new(self, @options[:registry])
        @transporter = resolve_transporter(@options[:transporter])
        @transit     = Transit.new(self, @options[:transit])
      end

      def emit(event_name, payload: nil, groups: [])
        endpoints = @registry.get_event_endpoints(event_name, groups, false)
        emit_to_endpoints(endpoints, payload, groups)
        true
      end

      def broadcast(event_name, payload: nil, groups: [])
        endpoints = @registry.get_event_endpoints(event_name, groups)
        broadcast_to_endpoints(endpoints, payload, groups)
        true
      end

      def broadcast_local(event_name, payload: nil, groups: [])
        @local_bus.emit(event_name) if event_name =~ /^\$/
        endpoints = @registry.get_local_event_endpoints(event_name, groups, true)
        broadcast_to_endpoints(endpoints, payload, groups)
        true
      end

      def start
        @transit.connect
      end

      def stop; end

      def send_event(name, payload, groups, broadcast, node_id)
        @transit.send_event(name, payload, groups, broadcast, node_id)
      end

      def wait_for_services(*_services)
        true
      end

      def get_logger(*tags)
        super(tags.unshift(@node_id))
      end

      private

      def emit_to_endpoints(endpoints, payload, groups)
        call_event_endpoints(endpoints, payload, groups, false)
      end

      def broadcast_to_endpoints(endpoints, payload, groups)
        call_event_endpoints(endpoints, payload, groups, true)
      end

      def call_event_endpoints(endpoints, payload, groups, broadcast)
        endpoints.each do |endpoint|
          @logger.debug("Broadcast '#{endpoint.name}'." \
                          "#{(!groups.empty? ? " to '#{groups.join(', ')}' group(s)" : '')}.")
          endpoint.call(payload, groups, broadcast)
        end
      end

      def emit_local_services(event_name, payload, groups, broadcast)
        @registry.emit_local_services(event_name, payload, groups, node_id, broadcast)
      end

      def resolve_transporter(transporter)
        Transporters.resolve(transporter)
      end

      def resolve_serializer(serializer)
        Serializers.resolve(serializer).new(self)
      end
    end
  end
end
