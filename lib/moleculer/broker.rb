# frozen_string_literal: true

require_relative "registry"
require_relative "broker/base"

module Moleculer
  ##
  # The Broker is the main component of Moleculer. It handles services, calls actions, emits events and communicates
  # with remote nodes. You must create a Broker instance on every node.
  #
  # ### Create a Broker
  #
  #  **Creating a new broker**
  #
  # ```ruby
  # require "moleculer"
  #
  # Moleculer::Broker.new
  # ```
  #
  # **Creating a new broker with custom settings**
  #
  # ```ruby
  # require "moleculer"
  #
  # Moleculer::Broker.new(node_id: "my-node")
  # ```
  module Broker
    ##
    # @return [Moleculer::Broker::Base] an instance of a Moleculer service broker
    def self.new(options = {})
      Base.new(options)
    end
  end
end
