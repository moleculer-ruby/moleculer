# frozen_string_literal: true

module Moleculer
  module Service
    module Settings
      module ClassMethods
        ##
        # Sets or gets the settings. If a value is passed the settings are set and merged with ancestor service
        # classes.
        #
        # @param [Hash] value the settings for the service
        #
        # @return [Hash] the settings for the service, including merged settings from ancestors classes
        def settings(value = nil)
          if value || @settings.nil?
            @settings = value || {}
            ancestors.each do |ancestor|
              @settings = ancestor.settings.merge(@settings) if ancestor.respond_to?(:settings)
            end
          end
          @settings
        end

        ##
        # Gets or sets the no version prefix setting. When set, no version prefix will be required
        # to call the service.
        #
        # @param [Boolean] value the value to set the setting to
        #
        # @return [Boolean] the value of no_version_prefix
        def no_version_prefix(value = nil)
          settings[:$no_version_prefix] = value unless value.nil?
          settings[:$no_version_prefix] = true if settings[:$no_version_prefix].nil?
          settings[:$no_version_prefix]
        end
      end

      def self.included(mod)
        mod.extend ClassMethods
      end

      private

      def settings
        self.class.settings
      end

      def settings_schema
        @settings_schema ||= without_secure_settings(settings).reject { |k, _v| k.to_s[0] == "$" }
      end

      def without_secure_settings(hash)
        return hash unless hash[:$secure_settings]

        sets = hash.dup

        hash[:$secure_settings].each do |ss|
          path = ss.to_s.split(".")

          leaf = path.pop
          path.inject(sets) { |h, el| h[el.to_sym] }.delete leaf.to_sym
        end

        sets
      end
    end
  end
end
