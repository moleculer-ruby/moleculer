# frozen_string_literal: true

require_relative "local_event_bus"
require_relative "../transit"


module Moleculer
  module Broker
    attr_reader :local_bus

    ###
    # Event related broker functionality
    module Events
      def initialize(*)
        @local_bus = LocalEventBus.new
        super
      end

      def broadcast(event_name, payload: nil, groups: [])
        endpoints = registry.get_event_endpoints(event_name, groups)
        broadcast_to_endpoints(endpoints, payload, groups)
        true
      end

      def broadcast_local(event_name, payload: nil, groups: [])
        @local_bus.emit(event_name) if event_name =~ /^\$/
        endpoints = registry.get_local_event_endpoints(event_name, groups, true)
        broadcast_to_endpoints(endpoints, payload, groups)
        true
      end

      def emit(event_name, payload: nil, groups: [])
        endpoints = registry.get_event_endpoints(event_name, groups, false)
        emit_to_endpoints(endpoints, payload, groups)
        true
      end

      def send_event(name, payload, groups, broadcast, node_id)
        transit.send_event(name, payload, groups, broadcast, node_id)
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
    end
  end
end
