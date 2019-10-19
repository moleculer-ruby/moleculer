# frozen_string_literal: true

require_relative "./base_packet_behavior"

RSpec.describe Moleculer::Packets::Event do
  let(:config) { double(Moleculer::Configuration, node_id: "test1") }
  let(:node) { double("node", id: 1) }

  subject { Moleculer::Packets::Event.new(config, event: "test", data: {}, broadcast: false, node: node) }

  include_examples "base packet"

  describe "#topic" do
    it "includes the node id" do
      expect(subject.topic).to eq("MOL.EVENT.test1")
    end
  end
end
