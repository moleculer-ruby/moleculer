# frozen_string_literal: true

require_relative "base_packet_behavior"
require_relative "targeted_packet_behavior"


RSpec.describe Moleculer::Packets::Res do
  let(:broker) do
    Moleculer::Broker.new(Moleculer::Configuration.new(
                            node_id:     "test1",
                            services:    [],
                            log_level:   "trace",
                            transporter: "fake://localhost",
                          ))
  end

  subject { Moleculer::Packets::Res.new(broker.config, id: "1", success: true, data: {}, target_node: "other") }

  include_examples "base packet"
  include_examples "targeted packet"
end
