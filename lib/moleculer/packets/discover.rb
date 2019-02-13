# frozen_string_literal: true

# frozen_string_literal: true

require_relative "./base"

module Moleculer
  module Packets
    class Discover < Base
      NAME = "DISCOVER"

      field :ver
      field :sender

    end
  end
end
