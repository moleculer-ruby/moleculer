# frozen_string_literal: true

require "spec_helper"

RSpec.describe Moleculer::Broker do
  let(:broker) { described_class.new }

  describe "#initialize" do
    it "creates a new broker instance" do
      expect(broker).to be_a(described_class)
    end
  end

  describe "#node_id" do
    context "with default node ID" do
      it "returns a random node ID" do
        expect(broker.send(:node_id)).to eq("#{Socket.gethostname}-#{Process.pid}")
      end
    end

    context "with custom node ID" do
      let(:broker) { described_class.new(node_id: "custom-node-id") }

      it "returns the custom node ID" do
        expect(broker.send(:node_id)).to eq("custom-node-id")
      end
    end
  end

  describe "#logger" do
    it "returns the logger instance" do
      expect(broker.logger).to be_a(Moleculer::Logger)
    end
  end

  describe "#start" do

  end
end
