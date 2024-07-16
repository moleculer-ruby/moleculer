# frozen_string_literal: true

require "spec_helper"

RSpec.describe Moleculer::Serializers::JSON do
  let(:broker) { Moleculer::Broker.new(logger: Console::Logger.new(Console::Output::Null.new)) }
  let(:serializer) { described_class.new(broker:) }
  describe "#serialize" do
    it "converts an object to JSON string" do
      object = { key: "value" }
      expect(serializer.serialize(object:, type: nil)).to eq(JSON.dump(object))
    end
  end

  describe "#deserialize" do
    it "converts a JSON string to a Ruby object" do
      json_string = '{"key":"value"}'
      expect(serializer.deserialize(data: json_string, type: nil)).to eq(JSON.parse(json_string))
    end
  end
end
