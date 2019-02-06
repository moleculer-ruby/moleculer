# frozen_string_literal: true

require_relative "./base"

module Moleculer
  module Packets
    # @private
    class Info < Base
      field :ver
      field :sender
      field :services
      field :config
      field :ipList
      field :hostname
      field :client
    end
  end
end
