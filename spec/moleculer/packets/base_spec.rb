# frozen_string_literal: true

require_relative "./base_packet_behavior"

RSpec.describe Moleculer::Packets::Base do
  let(:broker) { double(Moleculer::Broker, node_id: "test") }
  let(:config) { double(Moleculer::Configuration, broker: broker, node_id: "test") }
  let(:klass)  do
    Class.new(Moleculer::Packets::Base) do
      packet_attr :with_default, :default
      packet_attr :with_block_default, ->(packet) { "#{packet.with_default}_from_block" }
      packet_attr :no_data

      def self.name
        "Base"
      end
    end
  end

  subject { klass.new(config) }

  describe "::packet_attr" do
    subject { klass }

    it "returns the default when no value is defined" do
      expect(subject.new(config).with_default).to eq(:default)
    end

    it "evaluates the block and returns the default from the evaluated block" do
      expect(subject.new(config).with_block_default).to eq("default_from_block")
    end

    it "returns the value in the passed data" do
      expect(subject.new(config, with_default: 5).with_default).to eq(5)
    end

    it "throws an error when the data is not available" do
      expect { subject.new(config).no_data }.to raise_error(Moleculer::Errors::MissingValue)
    end
  end

  include_examples "base packet"

  describe "==" do
    context "equal packets" do
      subject { Moleculer::Packets::Base.new(config, ver: "4", sender: "not-node") }
      let(:right) { Moleculer::Packets::Base.new(config, ver: "4", sender: "not-node") }

      it "should be equal" do
        expect(subject).to eq(right)
      end
    end
  end
end
