RSpec.describe Moleculer::Registry do
  let(:broker) { instance_double(Moleculer::Broker) }
  subject { Moleculer::Registry.new(broker) }

  let(:local_node) { subject.instance_variable_get(:@local_node) }

  describe "#local_node" do
    it "returns the local node" do
      expect(subject.local_node).to be_a Moleculer::Node
      expect(subject.local_node.local?).to be_truthy
    end
  end

  describe "#register_local_service" do
    let(:service) { class_double(Moleculer::Service::Base, service_name: "test-service") }
    let(:actions) { subject.instance_variable_get(:@actions) }
    let(:action_1) { instance_double(Moleculer::Service::Action, name: "an-action", service: service) }

    it "registers the service with the local node" do
      allow(local_node).to receive(:register_service)
      subject.register_local_service(service)
      expect(subject.local_node).to have_received(:register_service).with(service)
    end

    it "updates the action mapping with the local_node actions" do
      allow(local_node).to receive(:register_service)
      allow(local_node).to receive(:actions).and_return([
        action_1
                                                        ])

      subject.register_local_service(service)

      expect(actions["test-service.an-action"]).to include(local_node)
    end
  end
end
