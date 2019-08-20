require_relative "../../../lib/moleculer/transporters/fake"

RSpec.describe Moleculer::Transporters::Fake do
  let(:config) { Moleculer::Configuration.new }
  let(:packet) { instance_double(Moleculer::Packets::Base, to_h: {}, topic: "test") }

  subject { Moleculer::Transporters::Fake.new(config) }

  before :each do
    subject.start
  end

  describe "#pulbish/#subscribe" do
    it "should publish and execute a subscribed channel" do
      executed = false
      subject.subscribe("test") do
        executed = true
      end

      subject.publish(packet)

      expect(executed).to be_truthy
    end
  end
end
