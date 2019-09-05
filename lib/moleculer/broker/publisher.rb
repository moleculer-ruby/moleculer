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

      def publish_heartbeat
        @broker.logger.trace "publishing heartbeat"
        publish(:heartbeat)
      end

      ##
      # Publishes the discover packet
      def publish_discover
        @broker.logger.trace "publishing discover request"
        publish(:discover)
      end

      ##
      # Publish targeted discovery to node
      def publish_discover_to_node_id(node_id)
        publish_to_node_id(:discover, node_id)
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
