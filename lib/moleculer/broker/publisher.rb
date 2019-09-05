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
      def publish_event(event_data)
        publish_to_node(:event, event_data.delete(:node), event_data)
      end

      ##
      # Publishes a heartbeat packet to all nodes
      def publish_heartbeat
        @broker.logger.trace "publishing heartbeat"
        publish(:heartbeat)
      end

      ##
      # Publishes the discover packet to all nodes
      def publish_discover
        @broker.logger.trace "publishing discover request"
        publish(:discover)
      end

      ##
      # Publish targeted discovery to node
      def publish_discover_to_node_id(node_id)
        publish_to_node_id(:discover, node_id)
      end

      ##
      # Publishes the info packet to either all nodes, or the given node
      # @param node_id [String] the node id to publish to
      # @param force [Boolean] allows an info packet to be published to a node even if the node is not listed in the
      #                        node registry
      def publish_info(node_id = nil, force = false)
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

      def publish_req(request_data)
        publish_to_node(:req, request_data.delete(:node), request_data)
      end

      def publish_res(response_data)
        publish_to_node(:res, response_data.delete(:node), response_data)
      end

      private

      def publish(packet_type, message = {})
        packet = Packets.for(packet_type).new(@broker.config, message.merge(sender: @broker.registry.local_node.id))
        @broker.transporter.publish(packet)
      end

      def publish_to_node(packet_type, node, message = {})
        packet = Packets.for(packet_type).new(@broker.config, message.merge(node: node))
        @broker.transporter.publish(packet)
      end
    end
  end
end
