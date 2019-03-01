# frozen_string_literal: true

require "singleton"


module Moleculer
  ##
  # A Service represents a microservice in the Moleculer framework. You can define actions and subscribe to events. To
  # create a service, you must include the Moleculer::Service module in a class. Service classes are intended to be
  # singleton classes, and should not be included in non-microservice classes, but instead a dedicated class for the
  # microservice.
  module Service

    def self.included(base)
      base.instance_eval do
        include Singleton
      end
      base.extend ClassMethods
    end

    def action(name, method, options={})

    end

    #
    # included do
    #   class_attribute :moleculer_actions, :moleculer_events, :autostart_moleculer_service, :moleculer_settings, :moleculer_metadata
    #
    #   self.moleculer_actions = ActiveSupport::HashWithIndifferentAccess.new
    #   self.moleculer_events = ActiveSupport::HashWithIndifferentAccess.new
    #
    #   Moleculer.register_service(self)
    # end

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


      def moleculer_metadata(metadata=nil)
        if metadata
          @metadata = metadata
        end
        @metadata
      end

      def moleculer_start

      end

      def moleculer_action_info
        info = {}
        moleculer_actions.each do |info|

        end
      end

      private

      def method_missing(method_id, *args)
        self.instance.public_send(method_id, *args)
      end

    end
  end
end
