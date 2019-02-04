require_relative "./base"

module Moleculer
  module Packets
    class Discover < Base
      NAME = "DISCOVER"

      field :ver,    String
      field :sender, String

    end
  end
end
