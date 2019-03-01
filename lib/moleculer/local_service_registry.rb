require "socket"

require_relative "./packets/info"
require_relative "./node"

module Moleculer
  class LocalServiceRegistry
    def initialize(broker)
      @broker = broker
      @services = {}
      @actions = {}
      @events = {}
    end

    def register(service)
      @services[service.moleculer_service_name] = service
      service.moleculer_actions.values.each { |a| @actions["#{service.moleculer_service_name}.#{a}"] = { name: a, service: service } }
      service.moleculer_events.each_pair do |event_name, method|
        @events[event_name] ||= []
        @events[event_name] << {method: method , service: service }
      end
    end

    def execute_action(action_name, request)
      action = @actions[action_name]
      begin
        response = action[:service].public_send(action[:name].to_sym, request)
        Packets::Response.new(
          {
            sender: @broker.node_id,
            id: request.id,
            success: true,
            stream: false,
            meta: request.meta,
            data: response
          },
          request
        )
      rescue StandardError => e
        Packets::Response.new(
          { sender: @broker.node_id,
            id: request.id,
            success: false,
            stream: false,
            meta: request.meta,
            error: {
              message: e.message,
              backtrace: e.backtrace
            } },
          request
        )
      end
    end

    def execute_event(packet)
      services = @events[packet.event]
      services.each { |s| s[:service].public_send(s[:method], packet) }
    end

    def to_info
      Packets::Info.new(
        sender:   @broker.node_id,
        services: service_info,
        config:   {},
        ipList:   Socket.ip_address_list.collect(&:ip_address),
        hostname: Socket.gethostname,
        client:   {
          type:        "ruby",
          version:     Moleculer::VERSION,
          langVersion: RUBY_VERSION
        }
      )
    end

    private

    def service_info
      @services.values.collect do |klass|
        Node::Service.from_class(klass).to_h
      end
    end
  end
end
