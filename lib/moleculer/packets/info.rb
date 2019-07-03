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
          @type         = HashUtil.fetch(data, :type)
          @version      = HashUtil.fetch(data, :version)
          @lang_version = HashUtil.fetch(data, :lang_version)
        end

        ##
        # @return [Hash] the object prepared for conversion to JSON for transmission
        def as_json
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
      def initialize(config, data)
        super(config, data)
        @services = HashUtil.fetch(data, :services)
        @config   = get_config(data)
        @ip_list  = HashUtil.fetch(data, :ip_list)
        @hostname = HashUtil.fetch(data, :hostname)
        @client   = Client.new(HashUtil.fetch(data, :client))
        node      = HashUtil.fetch(data, :node, nil)
        @node_id  = HashUtil.fetch(data, :node_id, node&.id)
      end

      def topic
        return "#{super}.#{@node_id}" if @node_id
        super
      end

      def as_json
        super.merge(
          services: @services,
          config:   @config.to_h,
          ipList:   @ip_list,
          hostname: @hostname,
          client:   @client.as_json,
        )
      end

      private

      def get_config(data)
        OpenStruct.new(Hash[HashUtil.fetch(data, :config).map { |i| [StringUtil.underscore(i[0]), i[1]] }])
      end
    end
  end
end
