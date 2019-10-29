# frozen_string_literal: true

RSpec.shared_examples "base packet" do
  describe "defaults" do
    describe "#ver" do
      it "defaults to '3'" do
        expect(subject.ver).to eq "3"
      end
    end

    describe "#sender" do
      it "defaults to broker.config#node_id" do
        expect(subject.sender).to eq config.node_id
      end
    end
  end

  describe "#topic" do
    it "returns the correct topic" do
      expect(subject.topic).to include(subject.class.name.split("::")[-1].upcase)
    end
  end

  describe "#to_h" do
    it "returns the version and sender" do
      expect(subject.to_h).to include("ver" => "3", "sender" => subject.sender)
    end
  end

  describe "::new" do
    it "correctly processes an incoming packet" do
      expect(subject.class.new(config, subject.to_h).to_h).to include(valid_hash)
    end
  end
end
