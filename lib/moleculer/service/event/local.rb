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
        # @option options [Boolean|Hash] :cache if true, will use default caching options, if a hash is provided caching
        # options will reflect the hash.
        # @option options [Hash] params list of param and param types. Can be used to coerce specific params to the
        # provided type.
        def initialize(name, service, method, options = {})
          super(name, service)
          @method  = method
          @service = service
          @options = options
        end

        ##
        # @param payload [Hash] the event payload
        #
        # @return [Moleculer::Support::Hash] returns a hash which will be converted into json for the response.
        def execute(payload = {})
          service.new.public_send(@method, payload)
        end
      end
    end
  end
end
