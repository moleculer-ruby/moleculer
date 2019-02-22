require "socket"

require_relative "./packets/info"
require_relative "./node"

module Moleculer
  class LocalServiceRegistry

    def initialize(broker)
      @broker = broker
      @services = {}
      @actions = {}
    end

    def register(service)
      @services[service.moleculer_service_name] = service
      service.moleculer_actions.values.each { |a| @actions["#{service.moleculer_service_name}.#{a}"] = {name: a, service: service }}
    end

    def execute_action(action_name, args)
      action = @actions[action_name]
      action[:service].public_send(action[:name].to_sym, args)
    end

    def to_info
      Packets::Info.new({
        sender:   @broker.node_id,
        services: service_info,
        config:   {},
        ipList:   Socket.ip_address_list.collect { |addr_info| addr_info.ip_address },
        hostname: Socket.gethostname,
        client:   {
          type:        "ruby",
          version:     Moleculer::VERSION,
          langVersion: RUBY_VERSION,
        }
      })
    end

    private

    def service_info
      @services.values.collect do |klass|
        Node::Service.from_class(klass).to_h
      end
    end

  end
end
