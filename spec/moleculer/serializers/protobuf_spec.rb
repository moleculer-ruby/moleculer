# frozen_string_literal: true

require_relative "../../../lib/moleculer/serializers/protobuf"
require_relative "serializer_behavior"

RSpec.describe Moleculer::Serializers::Protobuf::Serializer do
  let(:config) { Moleculer::Configuration.new }
  subject { Moleculer::Serializers::Protobuf::Serializer.new(config) }

  include_examples "serializer"

  describe "::new" do
    it "returns an instance of the actual Serializer class" do
      expect(Moleculer::Serializers::Protobuf.new(config)).to be_a(Moleculer::Serializers::Protobuf::Serializer)
    end
  end
end
