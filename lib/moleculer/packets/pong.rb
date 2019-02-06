require_relative "./base"

module Moleculer
  module Packets
    class  Ping < Base
      field :ver
      field :sender
      field :time
      field :arrived
    end
  end
end
