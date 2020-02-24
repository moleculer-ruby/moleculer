# frozen_string_literal: true

module Moleculer
  module Service
    ##
    # Represents a service event
    class Event
      attr_reader :name, :service, :options, :broker

      def initialize(service, name, method, options)
        @service = service
        @broker  = service.broker
        @name    = name
        @method  = method
        @options = options
      end

      def node_id
        @service.node_id
      end

      def call(payload, groups, broadcast = false)
        if @method == :__remote__
          @broker.send_event(@name, payload, groups, broadcast, node_id)
        else
          @service.public_send(@method, payload)
        end
      end

      def schema
        {}
      end

    end
  end
end
