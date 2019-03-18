require_relative "abstract"
module Moleculer
  module Service
    module Event
      ##
      # Represents a local event
      class Local < Abstract
        ##
        # @param name [String|Symbol] the name of the event.
        # @param method [Symbol] the service method to be called.
        # @param service [Moleculer::Service::Base] the moleculer service class
        # @param options [Hash] event options.
        # @option options [Hash] :group the group in which the event should belong, defaults to the service_name
        def initialize(name, service, method, options)
          super(name, service)
          @method  = method
          @service = service
          @options = options
          @group   = options[:group] || service.service_name
        end

        ##
        # @param payload [Hash] the event payload
        # @param sender [String] the node that sent the event
        # @param event [String] the actual event that matched and fired
        #
        # @return [Moleculer::Support::Hash] returns a hash which will be converted into json for the response.
        def execute(payload, sender, event)
          service.new.public_send(@method, payload, sender, event)
        end
      end
    end
  end
end
