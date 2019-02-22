module Moleculer
  class Node
    attr_reader :broken, :name, :is_self, :actions

    def initialize(info_packet, is_self)
      @is_self = is_self
      @broken = false
      @name = info_packet.sender
      @services, @service_index = parse_services(info_packet)
    end

    def actions
      @services.collect { |s| s.actions }.flatten
    end

    private

    def parse_services(info_packet)
      service_index = {}
      services = []
      info_packet.services.each_index do |idx|
        svc = info_packet.services[idx]
        next if svc["name"] =~ /^\$/
        service = parse_service(svc)
        service_index[service.name] = idx
        services << service
      end
      [services, service_index]
    end

    def parse_service(service)
      Node::Service.new(service)
    end
  end
end

require_relative "./node/service"
