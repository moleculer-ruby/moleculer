# frozen_string_literal: true

require_relative "./base"

module Moleculer
  module Packets
    class Info < Base
      NAME = "INFO"

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
