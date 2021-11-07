# frozen_string_literal: true

module Moleculer
  module Messages
    ##
    # When the node receives an `INFO` packet, it sends an `INFO` packet which contains
    # all mandatory information about the nodes and the loaded services.
    class Info
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

      def initialize(data)
        @hostname    = data["hostname"]
        @metadata    = data["metadata"]
        @instance_id = data["instance_id"]
        @seq         = data["seq"]
      end
    end
  end
end
