# frozen_string_literal: true

require "spec_helper"

RSpec.describe Moleculer::Packet do
  let(:packet) { described_class.new(target: "some-node") }

  describe "#initialize" do
    it "creates a new packet instance" do
      expect(packet).to be_a(described_class)
    end

    context "with defaults" do
      it "sets the defaults" do
        expect(packet.payload).to eq({})
        expect(packet.target).to eq("some-node")
        expect(packet.type).to eq(Moleculer::Packet::UNKNOWN)
      end
    end

    context "with explicit values" do
      let(:packet) { described_class.new(target: "some-node", type: Moleculer::Packet::EVENT, payload: { foo: "bar" }) }

      it "sets the values" do
        expect(packet.payload).to eq({ foo: "bar" })
        expect(packet.target).to eq("some-node")
        expect(packet.type).to eq(Moleculer::Packet::EVENT)
      end
    end
  end
end
