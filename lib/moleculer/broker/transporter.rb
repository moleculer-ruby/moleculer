# frozen_string_literal: true

require_relative "../transporters"

module Moleculer
  module Broker
    ##
    # Transporter configuration
    module Transporter
      attr_reader :transporter
      def initialize(*)
        @transporter = resolve_transporter(@options[:transporter])
        super
      end

      private

      def resolve_transporter(transporter)
        Transporters.resolve(transporter)
      end
    end
  end
end
