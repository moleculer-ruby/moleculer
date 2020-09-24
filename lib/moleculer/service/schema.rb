# frozen_string_literal: true

module Moleculer
  module Service
    module Schema
      module ClassMethods
        def from_schema(_schema)
          Class.new(self) do
          end
        end
      end

      # @return [Hash] the service schema
      def schema
        {
          name:      service_name,
          version:   version,
          full_name: full_name,
          settings:  settings_schema,
          metadata:  metadata,
          actions:   actions_schema,
          events:    events_schema,
        }
      end
    end
  end
end
