module Moleculer
  class ServiceRegistry

    def initialize(broker)
      @broker = broker
      @nodes = {}
      @services = {}
    end

    def register(info_packet)
      @nodes[info_packet.sender] = info_packet
      info_packet.services.each do |s|
        unless @services[s]
          @services[s] = []
        end
        @services[s] << info_packet.sender unless @services.include?(info_packet.sender)
      end
    end

  end
end
