require_relative "../../spec_helper"
require_relative "../../../lib/moleculer/transporters/redis"
RSpec.describe Moleculer::Transporters::Redis do
  before :each do
    subject.start
  end

  after :each do
    subject.stop
  end

  subject { Moleculer::Transporters::Redis.new(Moleculer::Configuration.new({log_level: :trace})) }

  describe "#publis/scubscribe" do
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

    it "is capable of publishing packets and receiving them" do
      received = false
      subject.subscribe(packet.topic) do
        received = true
      end

      subject.publish(packet)
      sleep 0.1 until received
      expect(received).to be_truthy
    end
  end
end
