# frozen_string_literal: true

module Moleculer
  module Registry
    ##
    # Node client information
    class Client
      # @return [String] Type of client implementation(`nodejs`, `java`, `go`)
      attr_reader :type

      # @return [String] Client (Moleculer) version
      attr_reader :version

      # @return [String] NodeJS/Java/Go version
      attr_reader :lang_version

      ##
      # Creates a new client instance from the provided schema
      #
      # @param [Hash] schema
      def self.from_schema(schema)
        new(**schema)
      end

      def initialize(type:, version:, lang_version:)
        @type         = type
        @version      = version
        @lang_version = lang_version
      end

      ##
      # @return [Hash] a dump of the client schema
      def to_schema
        {
          type:         type,
          version:      version,
          lang_version: lang_version,
        }
      end
    end
  end
end
