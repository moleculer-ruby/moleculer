RSpec.describe Moleculer::Broker do
  let(:packet) do
    Moleculer::Packets::Event.new(
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
                            node_id:   "test1",
                            services:  [service_1, service_2],
                            log_level: "trace",
                            transporter: "fake://localhost"
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
end
