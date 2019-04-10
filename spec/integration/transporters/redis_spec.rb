require_relative "../../spec_helper"
require_relative "../../../lib/moleculer/transporters/redis"
RSpec.describe Moleculer::Transporters::Redis do
  before :each do
    subject.connect
  end

  after :each do
    subject.disconnect
  end

  subject { Moleculer::Transporters::Redis.new(Moleculer::Configuration.new) }

  describe "pub/sub" do
    let(:receiver) { spy("receiver") }
    let(:packet) do
      instance_double(Moleculer::Packets::Info,
                      topic:   "MOL.INFO.test-321",
                      as_json: { sender:   "test-123",
                                 ver:      "3",
                                 services: [],
                                 ipList:   [],
                                 config:   {},
                                 hostname: "thehost",
                                 client:   {
                                   type:        1,
                                   version:     1,
                                   langVersion: 1,
                                 } })
    end
    before :each do
      allow(Moleculer).to receive(:node_id).and_return("test-321")
      @received = false
      subject.subscribe("MOL.INFO.test-321") do |p|
        @received = true
        receiver.receive(p.as_json)
      end
    end

    it "is capable of publishing packets and receiving them" do
      subject.publish(packet)
      sleep 0.1 until @received
      expect(receiver).to have_received(:receive).with(hash_including(packet.as_json))
    end
  end
end
