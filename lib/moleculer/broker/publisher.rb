# frozen_string_literal: true

module Moleculer
  class Broker
    ##
    # Handles the publishing of messages to the transporter
    class Publisher
      # @param broker [Broker] the broker instance
      def initialize(broker)
        @broker = broker
      end

      ##
      # Publishes an event
      # @param event_data [Hash] the event data to publish
      def event(event_data)
        publish_to_node(:event, event_data.delete(:node), event_data)
      end

      ##
      # Publishes a heartbeat packet to all nodes
      def heartbeat
        publish(:heartbeat)
      end

      ##
      # Publishes the discover packet to all nodes
      def discover
        publish(:discover)
      end

      ##
      # Publish targeted discovery to node
      # @param node_id [String] the node to publish the discover packet to
      def discover_to_node_id(node_id)
        publish_to_node_id(:discover, node_id)
      end

      ##
      # Publishes the info packet to either all nodes, or the given node
      # @param node_id [String] the node id to publish to
      # @param force [Boolean] allows an info packet to be published to a node even if the node is not listed in the
      #                        node registry
      # TODO: refactor this into more than one method to reduce the logic tree
      def info(node_id = nil, force = false)
        return publish(:info, @broker.registry.local_node.to_h) unless node_id

        node = @broker.registry.safe_fetch_node(node_id)
        if node
          publish_to_node(:info, node, @broker.registry.local_node.to_h)
        elsif force
          ## in rare cases there may be a lack of synchronization between brokers, if we can't find the node in the
          # registry we will attempt to force publish it (if force is true)
          publish_to_node_id(:info, node_id, @broker.registry.local_node.to_h)
        end
      end

      ##
      # Publishes an RPC request
      # @param request_data [Hash] the request data to publish to the node
      def req(request_data)
        publish_to_node(:req, request_data.delete(:node), request_data)
      end

      ##
      # Publishes an RPC response to the requesting node
      # @param response_data [Hash] the response data to publish
      def res(response_data)
        publish_to_node(:res, response_data.delete(:node), response_data)
      end

      private

      def publish(packet_type, message = {})
        publish_packet_for(packet_type, message.merge(sender: @broker.registry.local_node.id))
      end

      def publish_to_node(packet_type, node, message = {})
        publish(packet_type, message.merge(node: node))
      end

      def publish_to_node_id(packet_type, node_id, message = {})
        publish(packet_type, message.merge(node_id: node_id))
      end

      def publish_packet_for(packet_type, message)
        packet = Packets.for(packet_type).new(@broker.config, message)
        @broker.logger.trace("publishing '#{packet_type}'")
        @broker.logger.trace(packet.to_h)
        @broker.transporter.publish(packet)
      end
    end
  end
end
