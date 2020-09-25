# frozen_string_literal: true

module Moleculer
  ##
  # Transit is a wrapper around the transporter
  class Transit
    include Logging

    def initialize(broker, transporter, options)
      @broker      = broker
      @transporter = transporter
      @options     = options
    end
  end
end
