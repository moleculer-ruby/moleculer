# frozen_string_literal: true

require "spec_helper"

RSpec.describe Moleculer::Registry::Strategies::RoundRobin do
  let(:registry) { double("registry") }
  let(:strategy) { described_class.new(registry:) }

  describe "#initialize" do
    it "sets the index to 0" do
      expect(strategy.instance_variable_get(:@index)).to eq(0)
    end
  end

  describe "#select" do
    it "selects a node based on round-robin algorithm" do
      node1 = Moleculer::Registry::Node.new(id: "node1")
      node2 = Moleculer::Registry::Node.new(id: "node2")
      node3 = Moleculer::Registry::Node.new(id: "node3")

      list = [node1, node2, node3]

      expect(strategy.select(list)).to eq(node1)
      expect(strategy.select(list)).to eq(node2)
      expect(strategy.select(list)).to eq(node3)
      expect(strategy.select(list)).to eq(node1)
    end
  end
end
