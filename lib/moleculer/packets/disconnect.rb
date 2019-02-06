# frozen_string_literal: true

require_relative "./base"

module Moleculer
  module Packets
    # @private
    class Disconnect < Base
      field :ver
      field :sender
    end
  end
end
