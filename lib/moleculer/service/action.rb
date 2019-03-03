module Moleculer
  module Service

    ##
    # Represents a declared action on a service
    class Action
      attr_reader :service


      ##
      # Raised when an action does not return a hash
      class InvalidActionResponse < StandardError
        def initialize(response)
          super "Action must return a Hash, instead it returned a #{response.class.name}"
        end
      end

      ##
      # @param name [String|String] the name of the action.
      # @param method [Symbol] the service method to be called.
      # @param service [Moleculer::Service::Base] the moleculer service class
      # @param options [Hash] action options.
      # @option options [Boolean|Hash] :cache if true, will use default caching options, if a hash is provided caching
      # options will reflect the hash.
      # @option options [Hash] params list of param and param types. Can be used to coerce specific params to the
      # provided type.
      def initialize(name, method, service, options = {})
        @name    = name
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
        raise InvalidActionResponse.new(response) unless response.is_a? Hash
      end

    end
  end
end
