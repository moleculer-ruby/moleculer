module Moleculer
  class Node
    attr_reader :actions,
                :id,
                :services

    def initialize(options = {})
      @local    = options[:local] || false
      @services = []
      @actions  = []
      @id = options[:nodeId] || options.fetch(:node_id)
      @register_service_callback = options[:register_service_callback]
    end

    def register_service(service)
      @services[service.name] = service
      @register_service_callback.call(self, service) if @register_service_callback
    end

    def local?
      @local
    end
  end
end
