# frozen_string_literal: true

module Moleculer
  module Service
    module Naming
      module ClassMethods
        # @return [String] the full name of the service including the version prefix if the
        #         version prefix is set to true.
        def full_name
          return "#{version.is_a?(Integer) ? "v#{version}" : version}.#{service_name}" unless no_version_prefix

          service_name
        end

        ##
        # Gets or sets the version. If a value is passed, the version is set.
        #
        # @param [String|Integer] value version the version of the service
        #
        # @return [String|Integer] the version of the service.
        def version(value = nil)
          @version = value if value
          @version || "0"
        end

        ##
        # Gets or sets the name of the service
        #
        # @param [String] value the value to set the service_name to
        #
        # @return [String] the name of the service
        def service_name(value = nil)
          @service_name = value if value
          @service_name
        end
      end

      def self.included(mod)
        mod.extend ClassMethods
      end

      private

      def service_name
        self.class.service_name
      end

      def version
        self.class.version
      end

      def full_name
        self.class.full_name
      end
    end
  end
end
