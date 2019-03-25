require_relative "base"

module Moleculer
  module Packets
    ##
    # Represents a RES packet
    class Res < Base
      attr_reader :id,
                  :success,
                  :data,
                  :error,
                  :meta,
                  :stream

      def initialize(data)
        super(data)

        @id      = HashUtil.fetch(data, :id)
        @success = HashUtil.fetch(data, :success)
        @data    = HashUtil.fetch(data, :data)
        @error   = HashUtil.fetch(data, :error, nil)
        @meta    = HashUtil.fetch(data, :meta)
        @stream  = HashUtil.fetch(data, :stream, false)
      end
    end
  end
end
