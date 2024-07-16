module Module
  class Registry
    class Configuration
      ##
      #
      def initialize(strategy:, prefer_local: true, discoverer: nil)
        @strategy = strategy
        @prefer_local = prefer_local
        @discoverer = discoverer
      end
    end
  end
end