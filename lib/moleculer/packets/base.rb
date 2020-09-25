# frozen_string_literal: true

module Moleculer
  module Packets
    ##
    # Base packet
    class Base
      class << self
        attr_accessor :type
      end

      attr_reader :ver, :sender

      def initialize(id:, sender:)
        @ver    = Moelculer::POROTOCOL_VERSION
        @sender = sender
      end

      ##
      # @return [Hash] hash representation of the packet
      def to_h
        {
          ver: ver,
          sender: sender,
          id: id
        }
      end
    end
  end
end
