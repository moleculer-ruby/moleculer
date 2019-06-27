RSpec.describe Moleculer::Packets::Base do
  let(:broker) {
    Moleculer::Broker.new(Moleculer::Configuration.new(
      node_id:   "test1",
      services:  [],
      log_level: "trace",
      transporter: "fake://localhost",
      ))
  }

  subject { Moleculer::Packets::Base.new(broker.config)  }
  describe "defaults" do
    describe "#ver" do
      it "defaults to '3'" do
        expect(subject.ver).to eq "3"
      end
    end

    describe "#sender" do
      it "defaults to broker.config#node_id" do
        expect(subject.sender).to eq broker.config.node_id
      end
    end
  end

  describe "overrides" do
    subject { Moleculer::Packets::Base.new(broker.config, ver: "4", sender: "not-node")}
    describe "#ver" do
      it "uses data[:ver]" do
        expect(subject.ver).to eq "4"
      end
    end

    describe "#sender" do
      it "uses data[:sender]" do
        expect(subject.sender).to eq "not-node"
      end
    end
  end

  describe "#topic" do
    before :each do
      allow(Moleculer::Packets::Base).to receive(:name).and_return("Something::Packet")
    end

    it "returns the correct topic" do
      expect(subject.topic).to eq "MOL.PACKET"
    end
  end
end
