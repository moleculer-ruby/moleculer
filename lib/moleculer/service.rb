# frozen_string_literal: true

module Moleculer
  ##
  # The `Service` represents a microservice in the Moleculer framework. You can define
  # actions and subscribe to events.
  #
  # @example
  #   class MyService < Moleculer::Service
  #     name :my_service
  #     actions :my_action, :my_action
  #     events "some.event", :some_event
  #
  #     def my_action(ctx)
  #       # do things
  #     end
  #
  #     def some_event(ctx)
  #       # do things
  #     end
  #   end
  #
  # @abstract
  class Service
    ##
    # @private
    class Options
      attr_reader :name, :version

      def initialize(opts = {})
        @name    = opts["name"]
        @version = opts["version"]
      end
    end

    ##
    # @private
    class Action
      def initialize(opts = {})
        @service  = opts.fetch(:service)
        @endpoint = opts.fetch(:endpoint)
        @handler  = opts.fetch(:handler)
        @params   = opts.fetch(:params)
        @cache    = opts.fetch(:cache)
        @before   = opts.fetch(:before)
        @after    = opts.fetch(:after)
        @error    = opts.fetch(:error)
      end

      def call(ctx)
        service.public_send(handler, ctx)
      end

      private

      attr_reader :service, :endpoint, :handler, :params, :cache, :before, :after, :error
    end

    ##
    # @private
    class Event
      def initialize(opts = {})
        @service = opts.fetch(:service)
        @name    = opts.fetch(:event)
        @handler = opts.fetch(:handler)
        @group   = opts.fetch(:group)
      end

      def call(ctx)
        service.public_send(handler, ctx)
      end

      private

      attr_reader :service, :event, :handler, :params, :cache, :before, :after, :error
    end

    ##
    # Gets or sets the name of the service. If `name` is not specified, the name of is
    # returned. The `name` is a mandatory property so it must be defined. It’s the first
    # part of action name when you call it.
    #
    # @param [String] name The name of the service.
    #
    # @return [String] The name of the service.
    def self.name(name = nil)
      @name = name if name
      @name
    end

    ##
    # Gets or sets the version of the service. If `version` is not specified, the version
    # of is returned. The `version` is an optional property. Use it to run multiple
    # version from the same service. It is a prefix in the action name. It can be an
    # `Integer` or a `String`.
    #
    # @param [Integer|String] version The version of the service.
    #
    # @return [Integer|String] The version of the service.
    def self.version(version = nil)
      @version = version if version
      @version || 1
    end

    ##
    # Defines an action endpoint.
    #
    # @param [String] endpoint The endpoint of the action. Example `"add"`
    # @param [Symbol] handler The method the action is to call. Example `:add`
    # @param [Hash] options The options for the action.
    # @option options [Hash] :params The params for the action. Example `{a: "number"}`
    # @option options [Boolean] :cache The cache options for the action. Example `false`
    # @option options [Symbol] :before The before options for the action. Example `nil`
    # @option options [Symbol] :after The after options for the action. Example `nil`
    # @option options [Symbol] :error The error options for the action. Example `nil`
    def self.action(endpoint, handler, options = {})
      actions[endpoint] = options.merge({
                                          endpoint: "#{name}.endpoint",
                                          handler:  handler,
                                        })
    end

    ##
    # Defines an event endpoint.
    #
    # @param [String] event The pattern of the event. Example `"added"`
    # @param [Symbol] method The method the event is to call. Example `:added`
    # @param [Hash] options The options for the event.
    # @option options [String] :group The group of the event. Example `"user"`
    def self.event(event, handler, options = {})
      events[event] = options.merge({
                                      event:   event,
                                      handler: handler,
                                    })
    end

    ##
    # @private
    def self.actions
      @actions ||= {}
    end

    ##
    # @private
    def self.events
      @events ||= {}
    end

    ##
    # @return [String] The name of the service.
    attr_reader :name

    ##
    # @return [Integer] The version of the service.
    attr_reader :version

    ##
    # @return [Hash{String => Moleculer::Service::Action}] The actions for the service.
    attr_reader :actions

    ##
    # @return [Hash{String => Moleculer::Service::Event}] The events for the service.
    attr_reader :events

    def initialize(opts = nil)
      @name    = opts ? opts.name : self.class.name
      @version = opts ? opts.version : self.class.version
      set_actions
      set_events
    end

    private

    def set_actions
      @actions = self.class.actions.each_with_object({}) do |(key, options), hsh|
        hsh["#{name}.#{key}"] = Action.new(
          options.merge({
                          service:  self,
                          endpoint: "#{name}.#{options[:endpoint]}",
                          handler:  options[:handler],
                          params:   options[:params] || {},
                          cache:    options[:cache] || false,
                          before:   options[:before] || nil,
                          after:    options[:after] || nil,
                          error:    options[:error] || nil,
                        }),
        )
      end
    end

    def set_events
      @events = self.class.events.transform_values do |options|
        Event.new(
          options.merge({
                          service: self,
                          event:   options[:event],
                          handler: options[:handler],
                          group:   options[:group] || nil,
                        }),
        )
      end
    end

    def dot_to_regex(str)
      regex = str.gsub(/\./, "\\.").gsub(/\*/, "\\w*")
      Regexp.new("^#{regex}$")
    end

    def collect_events(str)
      this.class.events.select do |event, _|
        dot_to_regex(str).match?(event)
      end
    end
  end
end
