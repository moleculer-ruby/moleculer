module Moleculer
  module Service
    module Action
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
        # @param name [String|Symbol] the name of the action.
        # @param service [Moleculer::Service::Base] the moleculer service class
        def initialize(name, service)
          @name    = name.to_s
          @service = service
        end

        ##
        # @abstract
        def execute(_)
          raise NotImplementedError
        end
      end
    end
  end
end
