require_relative "abstract"
require_relative "action"
require_relative "./event"

module Moleculer
  module Service
    ##
    # @abstract subclass to define a local service.
    class Base < Abstract
      class << self
        # @!attribute [rw] service_prefix
        #   @return [string] a prefix to add to the service name. The service_prefix is inherited from the parent class
        #           if it is not already defined in the current class.
        attr_writer :service_prefix

        ##
        # returns the action defined by the service.
        attr_reader :actions

        ##
        # returns the events defined by the service.
        attr_reader :events

        def service_prefix
          return superclass.service_prefix if !@service_prefix && superclass.respond_to?(:service_prefix)

          @service_prefix
        end

        ##
        # Set the service_name to the provided name
        #
        # @param name [String] the name to which the service_name should be set
        def service_name(name = nil)
          @service_name = name if name
          return "#{service_prefix}.#{@service_name}" if service_prefix

          @service_name
        end

        ##
        # Defines an action on the service.
        #
        # @param name [String|Symbol] the name of the action.
        # @param method [Symbol] the method to which the action maps.
        # @param options [Hash] the action options.
        # @option options [Boolean|Hash] :cache if true, will use default caching options, if a hash is provided caching
        # options will reflect the hash.
        # @option options [Hash] params list of param and param types. Can be used to coerce specific params to the
        # provided type.
        def action(name, method, options = {})
          @actions     ||= {}
          @actions[name] = Action::Local.new(name, self, method, options)
        end

        ##
        # Defines an event on the service.
        #
        # @param name [String|Symbol] the name of the event.
        # @param method [Symbol] the method to which the event maps.
        def event(name, method)
          @events     ||= {}
          @events[name] = Event::Local.new(name, self, method, self)
        end
      end

      ##
      # returns the action defined on the service class
      # @see action
      def actions
        self.class.actions
      end

      ##
      # returns the events defined on the service class
      # @see events
      def events
        self.class.events
      end
    end
  end
end
