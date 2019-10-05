# frozen_string_literal: true

RSpec.describe Moleculer::Broker do
  let(:registry) { subject.instance_variable_get(:@registry) }

  let(:packet) do
    Moleculer::Packets::Event.new(
      subject,
      event:     "test.event",
      data:      {},
      broadcast: false,
    )
  end

  let(:service_1) do
    Class.new(Moleculer::Service::Base) do
      service_name "service_1"
      event "test.event", :test_event

      def test_event; end
    end
  end

  let(:service_2) do
    Class.new(Moleculer::Service::Base) do
      service_name "service_2"
      event "test.event", :test_event

      def test_event; end
    end
  end

  let(:event_1) { service_1.events["test.event"] }
  let(:event_2) { service_2.events["test.event"] }

  subject do
    Moleculer::Broker.new(Moleculer::Configuration.new(
                            node_id:     "test1",
                            services:    [service_1, service_2],
                            log_level:   "trace",
                            transporter: "fake://localhost",
                          ))
  end

  before :each do
    allow(event_1).to receive(:execute).with(packet.data, subject)
    allow(event_2).to receive(:execute).with(packet.data, subject)
  end

  describe "#process_event" do
    it "sends the event packet to all services with the registered event" do
      subject.send(:register_local_node)
      subject.process_event(packet)
      expect(event_1).to have_received(:execute).with(packet.data, subject)
      expect(event_2).to have_received(:execute).with(packet.data, subject)
    end
  end

  describe "heartbeats" do
    before :each do
      remote_broker.start
      subject.start
    end

    let(:remote_broker) do
      Moleculer::Broker.new(Moleculer::Configuration.new(
                              node_id:            "test2",
                              services:           [],
                              log_level:          "trace",
                              transporter:        "fake://localhost",
                              heartbeat_interval: 0.1,
                            ))
    end

    describe "with registered node" do
      before :each do
        sleep 0.1 until registry.safe_fetch_node("test2")
      end

      let(:node) { subject.instance_variable_get(:@registry).fetch_node("test2") }

      before :each do
        allow(node).to receive(:beat) { @beat = true }
      end

      it "should have called beat on the node" do
        sleep 0.1 until @beat
        expect(node).to have_received(:beat)
      end
    end

    describe "without registered node" do
      before :each do
        @discover_count = 0
        ## Sets up a listener on the fake broker for heartbeats
        subject.instance_variable_get(:@transporter).subscribe("MOL.DISCOVER.test2") do
          @discover_count += 1
        end
        allow(registry).to receive(:safe_fetch_node).and_return(nil)
      end

      it "should republish the discover request to the remote broker" do
        sleep 0.1 until @discover_count > 0
        expect(@discover_count > 0).to be_truthy
      end
    end
  end
end
