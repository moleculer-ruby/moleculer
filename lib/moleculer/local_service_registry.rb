require "socket"

require_relative "./packets/info"
require_relative "./node"

module Moleculer
  class LocalServiceRegistry

    def initialize(broker)
      @broker = broker
      info = {
          sender:   broker.node_id,
          services: [],
          config:   {},
          ipList:   Socket.ip_address_list,
          hostname: Socket.gethostname,
          client:   {
            type:        "ruby",
            version:     Moleculer::VERSION,
            langVersion: RUBY_VERSION,
          }
      }
      @info, @node = update_info(info)
    end

    def register(service)
      service_info = Node::Service.info_from_class(service)
      info_hash = @info.to_h
      info_hash[:services] << service_info
      @info, @node = update_info(info_hash)
      @services ||= HashWithIndifferentAccess.new
      @services[service_info[:name]] = service
      @actions ||= HashWithIndifferentAccess.new
      service.moleculer_actions.values.each { |a| @actions["#{service.moleculer_service_name}.#{a}".to_sym] = {name: a, service: service }}
    end

    def execute_action(action_name, args)
      action = @actions[action_name.to_sym]
      action[:service].public_send(action[:name].to_sym, args)
    end

    private

    def update_info(info)
      info = Packets::Info.new(info)
      node = Node.new(info, true)
      [info, node]
    end
  end
end
