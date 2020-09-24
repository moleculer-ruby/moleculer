# frozen_string_literal: true

require_relative "actions/endpoint"

module Moleculer
  module Service
    module Actions
      module ClassMethods
        # @return [Hash] a hash of all avaialble actions
        def actions
          @actions ||= {}
          @actions
        end

        ##
        # Declares an action on the service.
        #
        # @param [String] name the name of the action
        # @param [Symbol] method the method to call
        # @param [Integer] timeout the default timeout for the action call
        # @param [Boolean] cache whether or not to cache the action
        def action(name, method: nil, timeout: nil, cache: false, &block)
          actions[name] = Actions::Endpoint.new(
            self,
            name:    name,
            method:  method,
            timeout: timeout,
            cache:   cache,
            &block
          )
        end
      end

      def self.included(mod)
        mod.extend ClassMethods
      end

      private

      def actions_schema
        @actions_schema ||= actions.transform_values(&:schema)
      end

      def actions
        self.class.actions
      end
    end
  end
end
