# frozen_string_literal: true

module Moleculer
  module Node
    ##
    # @private
    class Base
      ##
      # @return [Hash] metadata of the node, defaults to `{}`
      attr_reader :metadata

      ##
      # @return [String] the hosname of the node.
      attr_accessor :hostname

      ##
      # @return [String] the id of the node
      attr_reader :id

      ##
      # @return [Boolean] whether the node is local, defaults to `false`
      attr_reader :local

      ##
      # @return [Array<Moleculer::Service>] the services of the node
      attr_accessor :services

      def initialize(options = {})
        @id             = options.fetch(:id)
        @available      = true
        @last_heartbeat = Time.now
        @local          = options[:local] || false
        @services       = (options[:services] || []).collect(&:new)
      end

      ##
      # @return [Hash] the actions for all services on this node
      def actions
        services.each_with_object({}) do |service, actions|
          actions.merge!(service.actions)
        end
      end

      ##
      # @return [Hash] the events for all services on this node
      def events
        services.each_with_object({}) do |service, events|
          events.merge!(service.events)
        end
      end

      ##
      # Calls the specified action with the provided context
      #
      # @param [String] endpoint the name of the action to call
      # @param [Moleculer::Context] context the context to call the action with
      def call(endpoint, context)
        actions[endpoint].call(context)
      end

      def to_info
        Packets::Info.from_node(self)
      end
    end
  end
end
