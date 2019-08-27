# frozen_string_literal: true

require_relative "../../../lib/moleculer/serializers/json"
RSpec.describe Moleculer::Serializers::Json do
  subject { Moleculer::Serializers::Json.new(Moleculer::Configuration.new) }
  describe "#deserialize" do
    let(:logger) { subject.instance_variable_get(:@config).logger }

    before :each do
      allow(logger).to receive(:error)
    end

    it "calls the rescue handler instead of blowing up when JSON serialization fails" do
      expect { subject.deserialize("foo") }.to_not raise_error
      expect(logger).to have_received(:error).with(instance_of(JSON::ParserError))
    end
  end
end
