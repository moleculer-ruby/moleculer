# frozen_string_literal: true

require "socket"
require_relative "base"

module Moleculer
  module Packets
    ##
    # Represents an INFO packet
    class Info < Base
      include Support
      include HashUtil

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
          dt            = Support::HashUtil::HashWithIndifferentAccess.from_hash(data)
          @type         = dt.fetch(:type, nil)
          @version      = dt.fetch(:version, nil)
          @lang_version = dt.fetch(:lang_version, nil)
        end

        ##
        # @return [Hash] the object prepared for conversion to JSON for transmission
        def to_h
          Support::HashUtil::HashWithIndifferentAccess.from_hash(
            type:         @type,
            version:      @version,
            lang_version: @lang_version,
          ).to_camelized_hash
        end
      end

      packet_attr :services
      packet_attr :config
      packet_attr :ip_list
      packet_attr :hostname
      packet_attr :client

      def initialize(config, data = {})
        super config, data
          .dup
          .merge(
            client: Client.new(HashWithIndifferentAccess.from_hash(data).fetch(:client)),
          )
      end

      def topic
        return "#{super}.#{@config.node_id}" if @config.node_id

        super
      end

      def to_h
        super.merge(HashWithIndifferentAccess.from_hash(
          services: services,
          config:   HashWithIndifferentAccess.from_hash(config_for_hash),
          ipList:   ip_list,
          hostname: hostname,
          client:   client.to_h,
        ).to_camelized_hash)
      end

      private

      def config_for_hash
        # TODO: Add from pairs method
        Hash[config.to_h.reject { |a, _| a == :log_file }]
      end
    end
  end
end
