# frozen_string_literal: true

RSpec.describe Moleculer::Packets::Base do
  subject {described_class.new}

  describe "#payload" do
    it "sets the version default" do
      expect(subject.payload[:ver]).to eq(Moleculer::PROTOCOL_VERSION)
    end
  end

  describe "#as_json" do
    it "returns the payload" do
      expect(subject.as_json).to eq(subject.payload)
    end
  end

  describe "#type" do
    it "returns the class name of the packet " do
      expect(subject.type).to eq(described_class.name.split("::")[-1])
    end
  end
end
