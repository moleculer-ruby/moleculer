# frozen_string_literal: true

module Moleculer
  ##
  # The `Service` represents a microservice in the Moleculer framework. You can define
  # actions and subscribe to events.
  class Service
    class ActionNotFound < StandardError; end

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
    # Gets or sets the name of the service. If `name` is not specified, the name of is
    # returned.
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
    # of is returned.
    #
    # @param [Integer] version The version of the service.
    #
    # @return [Integer] The version of the service.
    def self.version(version = nil)
      @version = version if version
      @version || 1
    end

    ##
    # Defines an action endpoint.
    #
    # @param [String] endpoint The endpoint of the action. Example `"add"`
    # @param [Symbol] method The method the action is to call. Example `:add`
    # @param [Hash] options The options for the action.
    def self.action(endpont, method, options = {})
      actions[endpont] = {
        method: method,
        **options,
      }
    end

    ##
    # @return [Hash] The actions for the service.
    def self.actions
      @actions ||= {}
    end

    ##
    # @return [String] The name of the service.
    attr_reader :name

    ##
    # @return [Integer] The version of the service.
    attr_reader :version

    def initialize(opts = nil)
      @name    = opts ? opts.name : self.class.name
      @version = opts ? opts.version : self.class.version
      @actions = self.class.actions
      @events  = {}
    end

    ##
    # Calls the method at the provided endpoint, with the provided context. If the action
    # was not found an exception will be raised.
    #
    # @param [String] endpoint The service endpoint.
    # @param [Hash] context The call context.
    #
    # @return [any] The result of the action.
    def call(endpoint, context)
      action = actions[endpoint]

      raise ActionNotFound, "No action found for endpoint: #{endpoint}" unless action

      public_send(action[:method], context)
    end

    private

    attr_reader :actions
  end
end
