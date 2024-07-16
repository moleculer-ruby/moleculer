# frozen_string_literal: true

module Moleculer
  module Transporters
    ##
    # The Transit class is responsible for sending and receiving messages through the configured transporter.
    # @private
    class Transit
      delegate :logger, to: :broker

      ##
      # @param broker [Moleculer::Broker] The broker instance.
      # @param transporter [Moleculer::Transporters::Base] The transporter instance.
      # @param disable_reconnect [Boolean] If true, the transporter will not attempt to reconnect if the connection is
      # lost.
      def initialize(broker:, transporter:, disable_reconnect: false)
        @broker = broker
        @transporter = transporter
        @disable_reconnect = disable_reconnect
      end

      ##
      # Connects the transporter.
      def connect
        logger.info("Connecting to transporter...")
        @transporter.connect

      rescue StandardError => e
        @logger.warn "Connection is failed. #{e.message}"
        @logger.error e
        return if @disable_reconnect

        sleep 5

        @logger.info "Reconnecting..."
        retry
      end

      private

      def after_reconnect(was_reconnect)
        if was_reconnect

        end
      end
    end
  end
end
