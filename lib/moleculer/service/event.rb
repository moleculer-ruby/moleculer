module Moleculer
  module Service
    class Event

      ##
      # @param name [String|String] the name of the action.
      # @param method [Symbol] the service method to be called.
      # @param service [Moleculer::Service::Base] the moleculer service class
      def initialize(name, method, service)
        @name    = name
        @method  = method
        @service = service
      end

    end
  end
end
