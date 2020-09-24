# frozen_string_literal: true

require_relative "events/endpoint"

module Moleculer
  module Service
    module Events
      module ClassMethods
        # @return [Hash] a hash of all event handlers
        def events
          @events ||= {}
          @events
        end

        ##
        # Defines an event on the service
        #
        # @param [String] name the name of the event
        # @param [String] group the group the event belongs to
        # @param [Symbol] the method the event should call.
        def event(name, group: nil, method: nil, &block)
          events[name] = Events::Endpoint.new(self, group: group, name: name, method: method, &block)
        end
      end

      def self.included(mod)
        mod.extend ClassMethods
      end

      private

      def events
        self.class.events
      end

      def events_schema
        @events_schema ||= events.transform_values(&:schema)
      end
    end
  end
end
