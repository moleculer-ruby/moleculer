require "moleculer/transporters/redis"
RSpec.describe Moleculer::Transporters::Redis do
  subject { Moleculer::Transporters::Redis.new }
  let(:redis) { instance_double(::Redis, disconnect!: true, publish: true) }
  before :each do
    allow(::Redis).to receive(:new).and_return(redis)
    subject.connect
  end

  after :each do
    subject.disconnect
  end

  describe "#publish" do
    let(:packet) { instance_double(Moleculer::Packets::Req, topic: "test", as_json: {info: "info"})}

    it "publishes packets messages to the packet topic" do
      subject.publish(packet)
      expect(redis).to have_received(:publish).with("test", packet.as_json.to_json)
    end
  end
end
