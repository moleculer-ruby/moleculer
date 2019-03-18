module Moleculer
  module Support
    ##
    # A module of functional methods for working with strings.
    module StringUtil
      extend self
      ##
      # Converts a string to lowerCamelCase.
      #
      # @param term [String] the term to convert
      def camelize(term)
        new_term = term.gsub(/(?:^|_)([a-z])/) { $1.upcase }
        new_term[0..1].downcase + new_term[2..-1]
      end

      ##
      # Makes an underscored, lowercase form from the expression in the string.
      #
      # @param term[String] the word to convert into an underscored string
      def underscore(term)
        term.gsub(/(?<!^)[A-Z]/) { "_#$&" }.downcase
      end
    end
  end
end
