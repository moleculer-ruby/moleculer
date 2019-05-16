require_relative "../errors/invalid_action_response"
require_relative "../support"
module Moleculer
  module Service
    ##
    # Represents a service event.
    class Event
      # @!attribute [r] name
      #   @return [String] the name of the action
      # @!attribute [r] service
      #   @return [Moleculer::Service] the service that this event is tied to
      attr_reader :name, :service

      ##
      # @param name [String] the name of the action
      # @param service [Moleculer::Service] the service to which the action belongs
      # @param method [Symbol] the method which the event calls when executed
      # @param options [Hash] the method options
      # TODO: add ability to group events
      def initialize(name, service, method, options = {})
        @name    = name
        @service = service
        @method  = method
        @service = service
        @options = options
      end

      ##
      # Executes the event
      # @param data [Hash] the event data
      # @param broker [Moleculer::Broker] the moleculer broker
      def execute(data, broker)
        @service.new(broker).public_send(@method, data)
      rescue StandardError => e
        raise e unless broker.rescue_event

        broker.rescue_event.call(e)
      end

      ##
      # @return [Moleculer::Node] the node of the service this event is tied to
      def node
        @service.node
      end

      ##
      # @return [Hash] a hash representing this event as it would be in JSON
      def as_json
        {
          name: name,
        }
      end
    end
  end
end
