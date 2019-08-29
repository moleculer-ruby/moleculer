# frozen_string_literal: true

require_relative "../../spec_helper"
require_relative "../../../lib/moleculer/transporters/redis"
RSpec.describe Moleculer::Transporters::Redis do
  before :each do
    subject.start
  end

  after :each do
    subject.stop
  end

  let(:config) { Moleculer::Configuration.new }

  ##
  # this allows us to wait until the transporter as fully connected
  subject do
    Class.new(Moleculer::Transporters::Redis) do
      attr_reader :started

      def start
        super
        sleep 0.1 until subscriber.instance_variable_get(:@started)
      end
    end.new(config)
  end

  describe "#publis/scubscribe" do
    let(:packet) do
      Moleculer::Packets::Info.new(
        config,
        topic:    "MOL.INFO.test-321",
        node_id:  "test-124",
        services: {},
        ip_list:  [],
        hostname: "thehost",
      )
    end

    before :each do
      allow(packet).to receive(:sender).and_return("not-this-node")
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
