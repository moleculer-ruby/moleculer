# frozen_string_literal: true

module Moleculer
  module Service
    module Metadata
      module ClassMethods
        def metadata(value = nil)
          if value || @metadata.nil?
            @metadata = value || {}
            ancestors.each do |ancestor|
              @metadata = ancestor.metadata.merge(@metadata) if ancestor.respond_to?(:metadata)
            end
          end
          @metadata
        end
      end

      def self.included(mod)
        mod.extend ClassMethods
      end

      private

      def metadata
        self.class.metadata
      end
    end
  end
end
