require_relative "../errors/invalid_action_response"
require_relative "../support"
module Moleculer
  module Service
    ##
    # Represents an action
    class Action
      include Support

      # @!attribute [r] name
      #   @return [String] the name of the action
      attr_reader :name

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
        @name    = name
        @service = service
        @method  = method
        @service = service
        @options = options
      end

      ##
      # @param context [Moleculer::Context] the execution contextd
      #
      # @return [Moleculer::Support::Hash] returns a hash which will be converted into json for the response.
      def execute(context)
        response = @service.new.public_send(@method, context)
        # rubocop:disable Style/RaiseArgs
        raise Errors::InvalidActionResponse.new(response) unless response.is_a? Hash

        response
      end

      def node
        @service.node
      end

      def as_json
        {
          name:    "#{@service.service_name}.#{name}",
          rawName: name,
          cache:   HashUtil.fetch(@options, :cache, false),
          metrics: {
            params: false,
            meta:   true,
          },
        }
      end
    end
  end
end