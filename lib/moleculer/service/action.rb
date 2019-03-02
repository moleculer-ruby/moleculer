module Moleculer
  module Service
    class Action

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

    end
  end
end
