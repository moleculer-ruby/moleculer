# frozen_string_literal: true

require_relative "../endpoint"

module Moleculer
  module Service
    module Events
      class Endpoint < Service::Endpoint
        def initialize(*args, group:, **kwargs)
          super(*args, **kwargs)
          @group = group
        end

        private

        attr_reader :group
      end
    end
  end
end
