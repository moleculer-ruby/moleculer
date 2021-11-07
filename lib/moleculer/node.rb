# frozen_string_literal: true

module Moleculer
  ##
  # A node represents an individual node.
  class Node
    ##
    # @return [Hash] metadata of the node, defaults to `{}`
    attr_reader :metadata

    ##
    # @return [String] the hosname of the node.
    attr_accessor :hostname

    ##
    # @return [String] the id of the node
    attr_reader :id

    ##
    # @return [Boolean] whether the node is local, defaults to `false`
    attr_reader :local

    def initialize(info, local: false)
      @id             = id
      @available      = true
      @last_heartbeat = Time.now
      @local          = local
      @info           = info
    end
  end
end
