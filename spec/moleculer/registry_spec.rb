# frozen_string_literal: true

require "spec_helper"

RSpec.describe Moleculer::Registry do
  describe "#initialize" do
    context "with default options" do
      it "initializes the registry" do
        broker = instance_double(Moleculer::Broker, logger: instance_double(Logger, info: nil))

        registry = described_class.new(
          broker:
        )

        expect(registry.send(:broker)).to eq broker
        expect(registry.send(:strategy)).to be_a Moleculer::Registry::Strategies::RoundRobin
        expect(registry.send(:discoverer)).to be_a Moleculer::Registry::Discoverers::Local
      end
    end
  end
end
