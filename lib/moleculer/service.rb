# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/class/attribute"
require "active_support/hash_with_indifferent_access"

module Moleculer
  module Service
    extend ActiveSupport::Concern

    included do
      class_attribute :moleculer_actions, :moleculer_events, :autostart_moleculer_service, :moleculer_settings, :moleculer_metadata

      self.moleculer_actions = ActiveSupport::HashWithIndifferentAccess.new
      self.moleculer_events = ActiveSupport::HashWithIndifferentAccess.new

      Moleculer.register_service(self)
    end

    def moleculer_broker
      self.class.moleculer_broker
    end

    module ClassMethods
      def moleculer_action(name, method)
        moleculer_actions[name] = method
      end

      def moleculer_broker
        Moleculer.broker
      end

      def moleculer_event(name, method)
        moleculer_events[name] = method
      end

      def moleculer_service_name(name=nil)
        if name
          @name = name
        end
        @name
      end


      def moleculer_settings(settings=nil)
        if settings
          @settings = settings
        end
        @settings
      end


      def moleculer_service_metadata(metadata=nil)
        if metadata
          @metadata = metadata
        end
        @metadata
      end

      def moleculer_start

      end
    end
  end
end
