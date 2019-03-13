require "redis"

# frozen_string_literal: true

require_relative "./base"

module Moleculer
  module Transporters
    ##
    # The Moleculer Redis transporter
    class Redis < Base
      include Concurrent::Async
      NAME = "Redis".freeze

      private

      def publisher
        @publisher ||= ::Redis.new(url: @uri, logger: @broker.logger)
      end
    end
  end
end
