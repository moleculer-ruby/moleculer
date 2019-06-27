require_relative "../../spec_helper"
require_relative "../../../lib/moleculer/transporters/redis"
RSpec.describe Moleculer::Transporters::Redis do
  before :each do
    subject.start
  end

  after :each do
    subject.stop
  end

  ##
  # this allows us to wait until the transporter as fully connected
  subject do
    Class.new(Moleculer::Transporters::Redis) do
      attr_reader :started

      def start
        super
        while !subscriber.instance_variable_get(:@started)
          sleep 0.1
        end
      end
    end.new(Moleculer::Configuration.new)
  end

  describe "#publis/scubscribe" do
    let(:packet) do
      instance_double(Moleculer::Packets::Info,
                      topic:   "MOL.INFO.test-321",
                               sender: "test-123",
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

      sleep 0.5

      subject.publish(packet)
      sleep 0.1 until received
      expect(received).to be_truthy
    end
  end
end
