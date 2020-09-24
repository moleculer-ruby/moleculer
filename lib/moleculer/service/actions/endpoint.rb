# frozen_string_literal: true

require_relative "../endpoint"

module Moleculer
  module Service
    module Actions
      class Endpoint < Service::Endpoint
        ##
        # @return [Boolean] the value of the action's default cache attribute
        attr_reader :cache

        ##
        # @return [Integer] the value of the actions timeout attribute
        attr_reader :timeout

        def initialize(*args, timeout:, cache:, **kwargs, &block)
          super(*args, **kwargs, &block)
          @timeout  = timeout
          @cache    = cache
        end

        ##
        # @return [String] the raw_ame of the action (without prefixes)
        def raw_name
          @name
        end

        ##
        # The name of the action, with the service name prefixed
        def name
          "#{service.service_name}.#{raw_name}"
        end

        def schema
          super.merge(
            cache:    cache,
            raw_name: raw_name,
            name:     name,
            params:   {},
            metrics:  {
              params: false,
              meta:   false,
            },
          )
        end
      end
    end
  end
end
