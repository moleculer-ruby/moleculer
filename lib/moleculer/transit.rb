# frozen_string_literal: true

module Moleculer
  ##
  # Transit provides the interface for all communication with the
  # chosen transporter.
  class Transit
    include SemanticLogger::Loggable

    def initialize(broker, transporter, options = {})
      @broker      = broker
      @transporter = transporter
      @options     = options
      @connected   = false
    end

    def connect
      logger.info("connecting")
      transporter.connect
      @connected = true
    end

    private

    attr_reader :transporter, :broker
  end
end
