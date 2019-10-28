# frozen_string_literal: true

require_relative "base_packet_behavior"
require_relative "targeted_packet_behavior"


RSpec.describe Moleculer::Packets::Res do
  let(:config) { double(Moleculer::Configuration, node_id: "test") }
  subject { Moleculer::Packets::Res.new(config, id: "1", success: true, data: {}, target_node: "other") }

  include_examples "base packet"
  include_examples "targeted packet"
end
