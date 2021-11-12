# frozen_string_literal: true

module Moleculer
  ##
  # @private
  class Node
    ##
    # @private
    class Client
      ##
      # @return [String] the type of client implementation, e.g. `'ruby'`
      attr_reader :type

      ##
      # @return [String] version of the client implementation, e.g. `'0.0.1'`
      attr_reader :version

      ##
      # @return [String] Ruby/NodeJS/Go version
      attr_reader :lang_version

      ##
      # @param [Hash] client the client information
      # @options client [String] type the type of client implementation, e.g. `'ruby'`
      # @options client [String] version the client (Moleculer) version
      # @options lang_version [String] Ruby/NodeJS/Go version
      def initialize(client = {})
        @type         = client.fetch(:type)
        @version      = client.fetch(:version)
        @lang_version = client.fetch(:lang_version)
      end

      ##
      # @return [Hash] a hash representation of the client
      def to_info
        {
          type:         @type,
          version:      @version,
          lang_version: @lang_version,
        }
      end
    end
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
    attr_reader :services

    ##
    # @return [String] the instance id of the node
    attr_reader :instance_id

    ##
    # @return [Array<String>] ip_list list of ip addresses of the node
    attr_reader :ip_list

    ##
    # @param [Hash] options the node options
    # @option options [String] :id the id of the node
    # @option options [String] :hostname the hostname of the node
    # @option options [Boolean] :local whether the node is local, defaults to `false`
    # @option options [String] :instance_id the instance id of the node
    # @option options [Hash] :metadata the metadata of the node, defaults to `{}`
    # @option options [Array<String>] :ip_list list of ip addresses of the node, defaults to `[]`
    # @option options [Array<Moleculer::Service>] :services the services of the node, defaults to
    #   `[]`
    # @option options [Moleculer::Node::Client] :client the client of the node
    def initialize(options = {})
      @id             = options.fetch(:id)
      @hostname       = options.fetch(:hostname)
      @available      = true
      @last_heartbeat = Time.now
      @local          = options[:local] || false
      @services       = (options[:services] || []).collect(&:new)
      @instance_id    = options.fetch(:instance_id)
      @metadata       = options.fetch(:metadata, {})
      @ip_list        = options.fetch(:ip_list, [])
      @client         = Client.new(options.fetch(:client))
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

    ##
    # @return [Hash] a hash representation of the node
    def to_info
      {
        sender:      id,
        services:    services.map(&:to_info),
        config:      {},
        instance_id: instance_id,
        ip_list:     ip_list,
        hostname:    hostname,
        client:      client.to_info,
        metadata:    {},
      }
    end
  end
end
