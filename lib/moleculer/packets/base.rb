# frozen_string_literal: true

require "forwardable"
require "ostruct"
require "json"

module Moleculer
  module Packets
    # @private
    class Base

      def initialize(packet={})
        packet = Moleculer::Support::Hash.from_hash(packet)
      end


    end
  end
end
