module Moleculer
  class Node
    class << self
      def from_remote_info(info_packet)
        services = info_packet.services.map { |service| Service.from_remote_info(service) }
        new(
          services: services,
          node_id:   info_packet.sender,
        )
      end
    end

    attr_reader :id,
                :services

    def initialize(options = {})
      @services = options.fetch(:services)
      @id       = options.fetch(:node_id)
      @local    = options.fetch(:local, false)
    end

    def register_service(service)
      @services[service.name] = service
    end

    def actions
      @services.map { |s|  s.actions.values }.flatten
    end

    def local?
      @local
    end
  end
end
