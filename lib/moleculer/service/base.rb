# frozen_string_literal: true

require_relative "action"
require_relative "event"

module Moleculer
  module Service
    ##
    # Service base class
    class Base
      class << self
        # @return [Hash] a hash of all avaialble actions
        def actions
          @actions ||= {}
          @actions
        end

        # @return [Hash] a hash of all event handlers
        def events
          @events ||= {}
          @events
        end

        def settings
          @settings ||= {}
        end

        def metadata
          @metadata ||= {}
        end

        def dependencies
          @dependencies ||= []
        end

        def dependency(dep)
          dependencies << dep
        end

        ##
        # Declares an action on the service.
        #
        # @param [String] name the name of the action
        # @param [Symbol] method the method to call
        # @param [Integer] timeout the default timeout for the action call
        # @param [Boolean] cache whether or not to cache the action
        def action(name, method: nil, timeout: nil, cache: false, &block)
          actions[name] = Action.new(self, name: name, method: method, timeout: timeout, cache: cache, &block)
        end

        def event(name, group: nil, method: nil, &block)
          events[name] = Event.new(self, group: group, name: name, method: method, &block)
        end

        # @return [String] the full name of the service including the version prefix if the
        #         version prefix is set to true.
        def full_name
          return "#{version.is_a?(Integer) ? "v#{version}" : version}.#{service_name}" unless no_version_prefix

          service_name
        end

        ##
        # Gets or sets the name of the service
        def service_name(value = nil)
          @service_name = value if value
          @service_name
        end

        ##
        # Gets or sets the no version prefix setting. When set, no version prefix will be required
        # to call the service.
        #
        # @param [Boolean] value the value to set the setting to
        #
        # @return [Boolean] the value of no_version_prefix
        def no_version_prefix(value = nil)
          settings[:$no_version_prefix] = value unless value.nil?
          settings[:$no_version_prefix] = true if settings[:$no_version_prefix].nil?
          settings[:$no_version_prefix]
        end

        ##
        # Gets or sets the version. If a value is passed, the version is set.
        #
        # @param [String|Integer] value version the version of the service
        #
        # @return [String|Integer] the version of the service.
        def version(value = nil)
          @version = value if value
          @version || "0"
        end
      end

      def initialize(broker)
        @broker = broker
      end

      def created; end

      def started; end

      def stopped; end

      def schema
        {
          name:      service_name,
          version:   version,
          full_name: full_name,
          # settings: settings,
          # metadata: metadata,
          actions:   actions_schema,
          events:    events_schema,
        }
      end

      private

      def service_name
        self.class.service_name
      end

      def version
        self.class.version
      end

      def full_name
        self.class.full_name
      end

      def actions_schema
        @actions_schema ||= actions.transform_values(&:schema)
      end

      def actions
        self.class.actions
      end

      def events
        self.class.events
      end

      def events_schema
        @events_schema ||= events.transform_values(&:schema)
      end
    end
  end
end
