# frozen_string_literal: true

require "socket"
require_relative "base"

module Moleculer
  module Packets
    ##
    # Represents an INFO packet
    class Info < Base
      ##
      # Represents the client information for a given node
      class Client
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

      packet_attr :services
      packet_attr :ip_list
      packet_attr :hostname
      packet_attr :client, {}
      packet_attr :node, nil
      packet_attr :node_id, ->(packet) { packet.sender || packet.node.id }

      def initialize(*args)
        super
        @client = Client.new(client)
      end

      def topic
        return "#{super}.#{node_id}" if node_id

        super
      end

      def to_h
        super.merge(
          services: services,
          config:   config_for_hash,
          ipList:   ip_list,
          hostname: hostname,
          client:   @client.to_h,
        )
      end

      private

      def config_for_hash
        ::Hash[config.to_h.reject { |a, _| a == :log_file }]
      end
    end
  end
end
