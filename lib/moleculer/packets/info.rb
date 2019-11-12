require "socket"
require_relative "base"

module Moleculer
  module Packets
    ##
    # Represents an INFO packet
    class Info < Base
      include Support

      ##
      # Represents the client information for a given node
      class Client
        include Support

        # @!attribute [r] type
        #   @return [String] type of client implementation (nodejs, java, ruby etc.)
        # @!attribute [r] version
        #   @return [String] the version of the moleculer client
        # @!attribute [r] lang_version
        #   @return [String] the client type version
        attr_reader :type,
                    :version,
                    :lang_version

        def initialize(data)
          @type         = Support::Hash.fetch(data, :type, nil)
          @version      = Support::Hash.fetch(data, :version, nil)
          @lang_version = Support::Hash.fetch(data, :lang_version, nil)
        end

        ##
        # @return [Hash] the object prepared for conversion to JSON for transmission
        def to_h
          {
            type:        @type,
            version:     @version,
            langVersion: @lang_version,
          }
        end
      end

      # @!attribute [r] services
      #   @return [Array<Moleculer::Services::Remote|Moleculer::Services::Base>] an array of the services the endpoint
      #           provides
      # @!attribute [r] config
      #   @return [Moleculer::Support::OpenStruct] the configuration of the node
      # @!attribute [r] ip_list
      #   @return [Array<String>] a list of the node's used IP addresses
      # @!attribute [r] hostname
      #   @return [String] the hostname of the node
      # @!attribute [r] client
      #   @return [Moleculer::Packets::Info::Client] the client data for the node
      attr_reader :services,
                  :config,
                  :ip_list,
                  :hostname,
                  :client

      ##
      # @param data [Hash] the packet data
      # @options data [Array<Hash>|Moleculer::Services::Base] services the services information
      # @options data [Hash] config the configuration data for the node
      # @options data [Array<String>] ip_list the list of ip addresses for the node
      # @options data [String] hostname the hostname  of the node
      # @options data [Hash] client the client data for the node
      def initialize(config, data = {})
        super(config, data)
        @services = Support::Hash.fetch(data, :services)
        @ip_list  = Support::Hash.fetch(data, :ip_list)
        @hostname = Support::Hash.fetch(data, :hostname)
        @client   = Client.new(Support::Hash.fetch(data, :client, {}))
        node      = Support::Hash.fetch(data, :node, nil)
        @node_id  = Support::Hash.fetch(data, :node_id, node&.id)
      end

      def topic
        return "#{super}.#{@node_id}" if @node_id

        super
      end

      def to_h
        super.merge(
          services: @services,
          config:   config_for_hash,
          ipList:   @ip_list,
          hostname: @hostname,
          client:   @client.to_h,
        )
      end

      private

      def config_for_hash
        Hash[config.to_h.reject { |a, _| a == :log_file }]
      end
    end
  end
end
