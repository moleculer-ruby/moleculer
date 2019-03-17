module Moleculer
  module Node
    ##
    # @abstract Subclassed for LocalNode and RemoteNode representing nodes registered on the local broker and nodes
    # registered on remote brokers respectively.
    class Base
      attr_reader :actions,
                  :id,
                  :services

      def initialize(options = {})
        @services = []
        @actions  = []
        @id = options[:nodeId] || options.fetch(:node_id)
      end

      def register_service(service)
        @services[service.name] = service
      end

      def local?
        false
      end
    end
  end
end