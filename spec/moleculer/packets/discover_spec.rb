# frozen_string_literal: true

require_relative "./base_packet_behavior"

RSpec.describe Moleculer::Packets::Discover do
  let(:broker) do
    Moleculer::Broker.new(Moleculer::Configuration.new(
                            node_id:     "test1",
                            services:    [],
                            log_level:   "trace",
                            transporter: "fake://localhost",
                          ))
  end

  subject { Moleculer::Packets::Discover.new(broker.config) }
  include_examples "base packet"

  describe "with node id" do
    subject { Moleculer::Packets::Discover.new(broker.config, node_id: "1") }

    describe "#topic" do
      it "returns the topic with the node id" do
        expect(subject.topic).to eq("MOL.DISCOVER.1")
      end
    end
  end

  describe "without node id" do
    subject { Moleculer::Packets::Discover.new(broker.config) }

    describe "#topic" do
      it "returns the topic with the node id" do
        expect(subject.topic).to eq("MOL.DISCOVER")
      end
    end
  end
end
