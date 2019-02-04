require "redis"

require_relative "./base"

module Moleculer
  module Transporters
    class Redis < Base
      NAME = "Redis"

      def connect
        @broker.logger.info "Connecting to Redis transporter"
        @redis = ::Redis.new(url: @uri)
      end

      def broadcast(packet)
        @broker.logger.debug "Broadcasting #{packet.name} packet"
        @redis.publish(packet.topic, packet.serialize)
      end
    end
  end
end
