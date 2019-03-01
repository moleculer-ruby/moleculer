module Moleculer
  class Registry
    def initialize(broker)
      @broker = broker
      @nodes = {}
      @actions = {}
      @events = {}
    end
  end
end
