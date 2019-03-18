require_relative "abstract"
require_relative "../../errors/invalid_action_response"
module Moleculer
  module Service
    module Action
      ##
      # Represents a local action
      class Local < Abstract
        ##
        # @param name [String|Symbol] the name of the action.
        # @param method [Symbol] the service method to be called.
        # @param service [Moleculer::Service::Base] the moleculer service class
        # @param options [Hash] action options.
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
        # @param context [Moleculer::Context] the execution context
        #
        # @return [Moleculer::Support::Hash] returns a hash which will be converted into json for the response.
        def execute(context)
          response = service.new.public_send(@method, context)
          # rubocop:disable Style/RaiseArgs
          raise Errors::InvalidActionResponse.new(response) unless response.is_a? Hash
        end
      end
    end
  end
end
