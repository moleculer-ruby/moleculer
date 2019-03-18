module Moleculer
  module Service
    module Event
      ##
      # @abstract Subclass to implement even types (local | remote)
      class Abstract
        ##
        # The service the event is attached to
        attr_reader :service

        ##
        # The name of the event
        attr_reader :name

        # @!attribute [r] group
        #   @return [String] the group to which the vents belongs

        ##
        # @param name [String|Symbol] the name of the event.
        # @param service [Moleculer::Service::Base] the moleculer service class
        def initialize(name, service)
          @name    = name.to_s
          @service = service
        end

        ##
        # @abstract
        def group
          raise NotImplementedError
        end

        ##
        # @abstract
        def execute(*_args)
          raise NotImplementedError
        end
      end
    end
  end
end
