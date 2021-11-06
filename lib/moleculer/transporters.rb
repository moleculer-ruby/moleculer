# frozen_string_literal: true

require_relative "transporters/fake"

module Moleculer
  module Transporters
    def self.get(name)
      case name
      when "fake"
        Transporters::Fake
      else
        raise ArgumentError, "Transporter #{name} not found"
      end
    end
  end
end
