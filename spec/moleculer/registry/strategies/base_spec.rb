# frozen_string_literal: true

require "spec_helper"

RSpec.describe Moleculer::Registry::Strategies::Base do
  let(:registry) { double("registry") }
  let(:strategy) { described_class.new(registry:) }

  describe "#initialize" do
    it "sets the registry" do
      expect(strategy.instance_variable_get(:@registry)).to eq(registry)
    end
  end

  describe "#select" do
    it "raises NotImplementedError" do
      expect { strategy.select([]) }.to raise_error(NotImplementedError)
    end
  end
end
