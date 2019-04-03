RSpec.describe Moleculer::Registry do
  let(:action_1) { instance_double(Moleculer::Service::Action, name: "service-1.test") }
  let(:service_1)  { class_double(Moleculer::Service::Base, service_name: "service-1", events: {}) }
  let(:node_1) do
    instance_double(Moleculer::Node,
                    actions:  {
                      "service-1.test" => action_1,
                    },
                    events:   {},
                    local?:   false,
                    id:       "node-1",
                    services: {
                      "service-1" => service_1,
                    })
  end

  let(:action_1_2) { instance_double(Moleculer::Service::Action, name: "service-1.test") }
  let(:service_1_2)  { class_double(Moleculer::Service::Base, service_name: "service-1", events: {}) }
  let(:node_2) do
    instance_double(Moleculer::Node,
                    actions:  {
                      "service-1.test" => action_1_2,
                    },
                    events:   {},
                    local?:   false,
                    id:       "node-2",
                    services: {
                      "service-1" => service_1_2,
                    })
  end

  let(:broker) { instance_double(Moleculer::Broker) }

  subject { Moleculer::Registry.new(broker) }

  before :each do
    allow(action_1).to receive(:node).and_return(node_1)
    allow(action_1_2).to receive(:node).and_return(node_2)
    subject.register_node(node_1)
    subject.register_node(node_2)
  end

  describe "#fetch_action" do
    it "retrieves the action in round robin fashion" do
      expect(subject.fetch_action("service-1.test")).to eq(action_1)
      expect(subject.fetch_action("service-1.test")).to eq(action_1_2)
      expect(subject.fetch_action("service-1.test")).to eq(action_1)
    end
  end
end
