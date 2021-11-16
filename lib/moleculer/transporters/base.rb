# frozen_string_literal: true

module Moleculer
  module Transporters
    ##
    # Base transporter class
    class Base
      include SemanticLogger::Loggable

      attr_reader :connected

      def initialize(config, serializer:)
        @config     = config
        @connected  = false
        @serializer = serializer
        @prefix     = "MOL-"
      end

      def connect
        raise NotImplementedError
      end

      def disconnect
        raise NotImplementedError
      end

      ##
      # Subscribes to a moleculer topic
      #
      # @param cmd [String] the cmd to subscribe to
      # @param node_id [String] the node id to subscribe to
      def subscribe(cmd, node_id = nil)
        raise NotImplementedError
      end

      def subscribe_balanced_request
        raise NotImplementedError
      end

      def subscribe_balanced_event
        raise NotImplementedError
      end

      def send
        raise NotImplementedError
      end

      private

      attr_reader :config, :serializer, :prefix

      def get_topic_name(cmd, node_id)
        "#{prefix}#{cmd}#{node_topic(node_id)}"
      end

      def node_topic(node_id)
        return ".#{node_id}" if node_id

        ""
      end

      def receive(cmd, payload)
        message = serializer.deserialize(payload)
        Packets.from(cmd, message)
      end
    end
  end
end
