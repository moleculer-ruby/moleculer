# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Moleculer::Packets do
  describe "#from" do
    let(:packet)  { double(Moleculer::Packets::Info) }
    let(:payload) { double("payload") }

    it "should create a new packet from the provided command" do
      expect(Moleculer::Packets::Info).to receive(:new).with(payload).and_return(packet)

      Moleculer::Packets.from("INFO", payload)
    end
  end
end
