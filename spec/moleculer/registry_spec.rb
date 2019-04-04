RSpec.describe Moleculer::Registry do
  let(:service_1_1) do
    Class.new(Moleculer::Service::Base) do
      service_name "service-1"
      action "test", :action_1

      def action_1; end
    end
  end

  let(:action_1_1) { service_1_1.actions.values.first }

  let(:service_2_1) do
    Class.new(Moleculer::Service::Base) do
      service_name "service-1"
      action "test", :action_1

      def aciton_1; end
    end
  end

  let(:action_2_1) { service_2_1.actions.values.first }

  let(:node_1) do
    Moleculer::Node.new(
      node_id:  "node-1",
      services: [service_1_1],
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
    allow(action_1_1).to receive(:node).and_return(node_1)
    allow(action_2_1).to receive(:node).and_return(node_2)
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
    end
  end
end
