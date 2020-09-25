# frozen_string_literal: true

RSpec.describe Moleculer::Catalogs::Base do
  let(:broker) { Moleculer::Broker.new }
  let(:registry) { Moleculer::Registry::Base.new(broker) }
  let(:node) { Moleculer::Node.new(broker, id: "test_node") }
  let(:service) { Moleculer::Service::Base.new(broker, node) }
  let(:other_service) { Moleculer::Service::Base.new(broker, node) }

  subject { Moleculer::Registry::ItemCatalog.new(registry, :actions) }

  let(:handler) { Moleculer::Service::Action.new(service, "test_action", "test_action", {}) }
  let(:other_handler) { Moleculer::Service::Action.new(service, "other_test_action", "test_action", {}) }

  describe "#register_items_for_node" do
    let(:test_service_handler) do
      Moleculer::Service::Action.new(service.new(broker, node), "test-service-handler", nil, {})
    end
    let(:service) do
      Class.new(Moleculer::Service::Base) do
        service_name "test-service"
      end
    end

    let(:other_test_service_handler) do
      Moleculer::Service::Action.new(service.new(broker, node), "other-test-service-handler", nil, {})
    end
    let(:other_service) do
      Class.new(Moleculer::Service::Base) do
        service_name "other-test-service"
      end
    end

    let(:node) { Moleculer::Node.new(broker, id: "test-node", services: [service, other_service]) }

    before :each do
      allow(node.services[service.service_name]).to receive(:actions)
        .and_return("test-service-handler": test_service_handler)
      allow(node.services[other_service.service_name]).to receive(:actions)
        .and_return("other-test-service-handler": other_test_service_handler)
    end

    it "registers all items of the node" do
      subject.register_items_for_node(node)
      expect(subject.instance_variable_get(:@store)["test-service.test-service-handler"])
        .to include(test_service_handler)
      expect(subject.instance_variable_get(:@store)["test-service.other-test-service-handler"])
        .to include(other_test_service_handler)
    end

    it "removes items that are no longer available on that service" do
      subject.register_items_for_node(node)
      subject.register_items_for_node(Moleculer::Node.new(broker, id: "test-node", services: [service]))
      expect(subject.instance_variable_get(:@store)["test-service.other-test-service-handler"]).to be_empty
    end
  end
end
