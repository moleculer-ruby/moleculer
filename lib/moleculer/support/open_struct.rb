require "ostruct"

module Moleculer
  module Support
    ##
    # An OpenStruct that supports camelized serialization for JSON
    class OpenStruct < ::OpenStruct
      ##
      # @return [Hash] the object prepared for conversion to JSON for transmission
      def to_h
        Hash[super.map { |item| [StringUtil.camelize(item[0]), item[1]] }]
      end
    end
  end
end
