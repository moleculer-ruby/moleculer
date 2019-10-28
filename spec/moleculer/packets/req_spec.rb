# frozen_string_literal: true

require_relative "./base_packet_behavior"

RSpec.describe Moleculer::Packets::Req do
  let(:config) { double(Moleculer::Configuration, node_id: "test") }
  let(:node) { double("node", id: 1) }

  subject do
    Moleculer::Packets::Req.new(config,
                                node:   node,
                                id:     SecureRandom.uuid,
                                action: "test",
                                meta:   {},
                                params: {})
  end

  include_examples "base packet"
end
