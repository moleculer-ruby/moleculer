# frozen_string_literal: true

module Moleculer
  class Broker
    ##
    # A Helper that encapsulates message processing logic
    # @private
    module MessageProcessor
      extend self

      ##
      # Processes an RPC response
      # @param context [Context] the call context
      # @param packet [Packet::Base] the message packet
      def process_rpc_response(context, packet)
        context[:future].fulfill(packet.data)
      end
    end
  end
end
