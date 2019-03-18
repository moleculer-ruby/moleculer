module Moleculer
  module Service
    module Event
      ##
      # @private
      # @abstract
      class Abstract
        ##
        # The service the action is attached to
        attr_reader :service

        ##
        # The name of the action
        attr_reader :name

        ##
        # @param name [String|Symbol] the name of the event.
        # @param service [Moleculer::Service::Base] the moleculer service class
        def initialize(name, service)
          @name    = name.to_s
          @service = service
        end

        ##
        # @abstract
        def execute(_payload)
          raise NotImplementedError
        end
      end
    end
  end
end
