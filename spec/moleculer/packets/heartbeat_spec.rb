# frozen_string_literal: true

require_relative "./base_packet_behavior"

RSpec.describe Moleculer::Packets::Heartbeat do
  let(:config) { double(Moleculer::Configuration, node_id: "test") }

  subject { Moleculer::Packets::Heartbeat.new(config) }

  include_examples "base packet"
end
