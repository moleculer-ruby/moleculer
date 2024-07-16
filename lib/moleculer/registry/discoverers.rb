# frozen_string_literal: true

require_relative "discoverers/base"
require_relative "discoverers/local"

module Moleculer
  class Registry
    ##
    # Moleculer framework has a built-in module responsible for node discovery and periodic heartbeat verification. The
    # discovery is dynamic meaning that a node don’t need to know anything about other nodes during start time. When it
    # starts, it will announce it’s presence to all the other nodes so that each one can build its own local service
    # registry. In case of a node crash (or stop) other nodes will detect it and remove the affected services from
    # their registry. This way the following requests will be routed to live nodes.
    module Discoverers
    end
  end
end
