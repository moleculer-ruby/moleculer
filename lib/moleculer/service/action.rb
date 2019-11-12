# frozen_string_literal: true

require_relative "../errors/invalid_action_response"
require_relative "../support"
module Moleculer
  module Service
    ##
    # Represents an action
    class Action
      REMOTE_IDENTIFIER = :__REMOTE__

      # @!attribute [r] name
      #   @return [String] the name of the action
      attr_reader :name, :service

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
        @options = options
      end

      ##
      # @param context [Moleculer::Context] the execution context
      #
      # @return [::Hash] returns a hash which will be converted into json for the response.
      # @raise [Errors::InvalidActionResponse] thrown when the result of calling the action does not return a hash
      def execute(context, broker)
        response = @service.new(broker).public_send(@method, context)
        # rubocop disabled because in this case we need a specific error handling format
        # TODO: I don't like this, but it makes it so we can treat remote service requests differently than normal
        #       requests without defining a remote action class. This probably needs to be refactored later
        raise Errors::InvalidActionResponse.new(response) unless response.is_a?(Hash) || response == REMOTE_IDENTIFIER # rubocop:disable Style/RaiseArgs

        Support::Hash.deep_symbolize(response)
      rescue StandardError => e
        broker.config.handle_error(e)
      end

      def node
        @service.node
      end

      def to_h
        {
          name:    "#{@service.full_name}.#{name}",
          rawName: name,
          cache:   Support::Hash.fetch(@options, :cache, false),
          metrics: {
            params: false,
            meta:   true,
          },
        }
      end
    end
  end
end
