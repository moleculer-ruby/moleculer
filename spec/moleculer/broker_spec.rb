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
                            logger: false,
                            transporter: "fake://localhost"
                          ))
  end

  before :each do
    allow(event_1).to receive(:execute).with(packet.data, subject)
    allow(event_2).to receive(:execute).with(packet.data, subject)
  end

  describe "#start" do
    let(:registry) { subject.instance_variable_get(:@registry) }
    let(:transporter) { subject.instance_variable_get(:@transporter) }
    let(:local_node) { registry.local_node }

    before :each do
      allow(transporter).to receive(:publish)
      subject.start
    end


    it "starts the broker" do
      expect(subject.started?).to eq(true)
    end

    it "registers the local node" do
      expect(subject.local_node).to eq(local_node)
    end

    it "subscribes to all of the transporter channels" do
      expect(transporter.subscriptions["MOL.INFO.#{local_node.id}"]).to_not be_nil
      expect(transporter.subscriptions["MOL.INFO"]).to_not be_nil
      expect(transporter.subscriptions["MOL.EVENT.#{local_node.id}"]).to_not be_nil
      expect(transporter.subscriptions["MOL.DISCOVER.#{local_node.id}"]).to_not be_nil
      expect(transporter.subscriptions["MOL.RES.#{local_node.id}"]).to_not be_nil
      expect(transporter.subscriptions["MOL.REQ.#{local_node.id}"]).to_not be_nil
      expect(transporter.subscriptions["MOL.HEARTBEAT"]).to_not be_nil
      expect(transporter.subscriptions["MOL.DISCOVER"]).to_not be_nil
      expect(transporter.subscriptions["MOL.DISCONNECT"]).to_not be_nil
    end

    it "publishes the discover and info packets" do
      expect(transporter).to have_received(:publish).twice
    end

    it "starts the heartbeat" do
      expect(subject.instance_variable_get(:@heartbeat)).to be_instance_of(Concurrent::TimerTask)
    end
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
