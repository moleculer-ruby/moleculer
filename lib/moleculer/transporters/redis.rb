require "redis"

# frozen_string_literal: true

require_relative "./base"
require_relative "../errors/transporter_already_started"

module Moleculer
  module Transporters
    ##
    # The Moleculer Redis transporter
    class Redis < Base
      include Concurrent::Async
      NAME = "REDIS".freeze

      def publish(packet)
        @logger.trace "publishing packet to '#{packet.topic}'", packet.as_json
        @publisher.publish(packet.topic, @serializer.serialize(packet))
      end

      def publish_to_node(packet, node)
        @logger.trace "publishing packet to '#{packet.topic}' on '#{node.id}'", packet.as_json
        @publisher.publish(packet.topic, @serializer.serialize(packet))
      end

      def start
        raise Errors::TransporterAlreadyStarted, "the transporter is already started" if @started.true?

        @started.make_true

        connect
        started_event = Concurrent::Promises.resolvable_event

        @main = Thread.new do
          @subscriber.psubscribe("MOL*") do |subscription|
            subscription.psubscribe do
              started_event.resolve
            end

            subscription.pmessage do |_, channel, message|
              begin
                parsed = @serializer.deserialize(message)
              rescue StandardError => e
                @logger.error e
              end
              @logger.trace "received message '#{channel}'", parsed
              @broker.process_message(channel, parsed)
            end
          end
        end
      end


      def started?
        @started.value
      end

      def stop
        disconnect
        @started.make_false
      end


      private

      def connect
        @logger.debug "connecting subscriber client on '#{@uri}'"
        @subscriber = ::Redis.new(url: @uri)
        @logger.debug "connecting publisher client on '#{@uri}'"
        @publisher = ::Redis.new(url: @uri)
      end

      def disconnect
        @logger.debug "disconnecting subscriber"
        @subscriber.disconnect!
        @logger.debug "disconnecting publisher"
        @publisher.disconnect!
      end

      def publisher
        @publisher ||= ::Redis.new(url: @uri, logger: @broker.logger)
      end
    end
  end
end
