module Moleculer
  class Node
    attr_reader :broken, :name, :is_self, :actions

    def initialize(info_packet, is_self)
      @is_self = is_self
      @broken = false
      @name = info_packet.sender
      @services = parse_services(info_packet)
    end

    def actions
      @services.collect { |s| s.actions }.flatten
    end

    private

    def parse_services(info_packet)
      info_packet.services.collect { |service|
        next if service["name"] =~ /^\$/
        parse_service(service)
      }.compact
    end

    def parse_service(service)
      Node::Service.new(service)
    end
  end
end

require_relative "./node/service"
