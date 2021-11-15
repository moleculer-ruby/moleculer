# frozen_string_literal: true

module Moleculer
  module Packets
    ##
    # When the node receives an `INFO` packet, it sends an `INFO` packet which contains
    # all mandatory information about the nodes and the loaded services.
    class Info
      TOPIC = "INFO"

      # method accepts a node, it calls #to_info on it and passes the resulting hash into
      # ::new with the info hash keys converted to camel case strings.
      def self.from_node(node)
        new(node.to_info)
      end

      ##
      # @return [Hash] Node-specific metadata.
      attr_reader :metadata

      ##
      # @return [String] Node hostname.
      attr_reader :hostname

      ##
      # @return [String] Node instance ID.
      attr_reader :instance_id

      ##
      # @return [Integer] The node update sequence number.
      attr_reader :seq

      ##
      # @return [String] The sender ID.
      attr_reader :sender

      ##
      # @return [Array<Hash>] The services.
      attr_reader :services

      ##
      # @return [Array<String>] the ip addresses of the node
      attr_reader :ip_list

      ##
      # @return [Hash] the client information
      attr_reader :client

      ##
      # @param data [Hash] Info packet data.
      def initialize(data)
        data.deep_symbolize_keys!

        @seq         = data["seq"]
        @services    = data["services"]
        @metadata    = (data["metadata"] || {}).deep_symbolize_keys
        @instance_id = data["instanceID"]
        @hostname    = data["hostname"]

        client_info = data["client"] || {}

        @client      = {
          type:         client_info["type"],
          version:      client_info["version"],
          lang_version: client_info["langVersion"],
        }
        @ip_list     = data["ipList"]
        @sender      = data["sender"]
      end

      ##
      # @return [Hash] The INFO packet data.
      def to_h
        {
          ver:         PROTOCOL_VERSION,
          sender:      sender,
          hostname:    hostname,
          metadata:    metadata,
          instance_id: instance_id,
          ip_list:     ip_list,
          client:      {
            type:         client[:type],
            version:      client[:version],
            lang_version: client[:lang_version],
          },
          services:    services,
          seq:         seq,
        }
      end
    end
  end
end
