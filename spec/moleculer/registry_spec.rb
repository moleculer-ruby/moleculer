RSpec.describe Moleculer::Registry do
  let(:service_1_1) do
    Class.new(Moleculer::Service::Base) do
      service_name "service-1"
      action "test", :action_1
      action "test2", :action_2
      event "test.update", :event_1

      def action_1; end

      def action_2; end

      def event_1; end
    end
  end

  let(:service_1_2) do
    Class.new(Moleculer::Service::Base) do
      service_name "service-1-2"
      event "test.update", :event_1

      def event_1; end
    end
  end

  let(:action_1_1) { service_1_1.actions.values.first }
  let(:event_1_1) { service_1_1.events.values.first }
  let(:event_1_2) { service_1_2.events.values.first }

  let(:service_2_1) do
    Class.new(Moleculer::Service::Base) do
      service_name "service-1"
      action "test", :action_1
      event "test.update", :event_1

      def action_1; end

      def event_1; end
    end
  end

  let(:action_2_1) { service_2_1.actions.values.first }
  let(:event_2_1) { service_2_1.events.values.first }

  let(:node_1) do
    Moleculer::Node.new(
      node_id:  "node-1",
      services: [service_1_1, service_1_2],
    )
  end

  let(:node_2) do
    Moleculer::Node.new(
      node_id:  "node-2",
      services: [service_2_1],
    )
  end

  let(:broker) { instance_double(Moleculer::Broker) }

  subject { Moleculer::Registry.new(broker) }

  before :each do
    allow(service_1_2).to receive(:node).and_return(node_1)
    allow(service_1_1).to receive(:node).and_return(node_1)
    allow(service_2_1).to receive(:node).and_return(node_2)
    subject.register_node(node_1)
    subject.register_node(node_2)
  end

  describe "#fetch_action" do
    it "retrieves the action in round robin fashion" do
      expect(subject.fetch_action("service-1.test")).to eq(action_1_1)
      expect(subject.fetch_action("service-1.test")).to eq(action_2_1)
      expect(subject.fetch_action("service-1.test")).to eq(action_1_1)
    end
  end

  describe "#fetch_events_for_emit" do
    it "retrieves the load balanced events for the given name" do
      expect(subject.fetch_events_for_emit("test.update")).to include(event_1_1, event_1_2)
      expect(subject.fetch_events_for_emit("test.update")).to include(event_2_1, event_1_2)
    end
  end

  describe "fetch_node" do
    it "retrieves the node for the given id" do
      expect(subject.fetch_node("node-1")).to eq(node_1)
    end

    it "raises an exception if the node was not found" do
      expect {subject.fetch_node("not-a-node")}.to raise_error(Moleculer::Errors::NodeNotFound)
    end
  end

  describe "#safe_fetch_node" do
    it "retrieves the node for the given id" do
      expect(subject.safe_fetch_node("node-1")).to eq(node_1)
    end

    it "returns nil if the node was not found" do
      expect(subject.safe_fetch_node("not-a-node")).to be_nil
    end
  end

  describe "#remove_node" do
    it "removes the node from the registry" do
      subject.remove_node("node-1")
      expect(subject.safe_fetch_node("node-1")).to be_nil
      expect { subject.fetch_action("service-1.test2") }.to raise_error(Moleculer::Errors::ActionNotFound)
      expect(subject.fetch_events_for_emit("test.update")).to_not include(event_1_1)
      subject.remove_node("node-2")
      subject.fetch_events_for_emit("test.update")
    end
  end
end
