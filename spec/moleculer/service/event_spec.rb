RSpec.describe Moleculer::Service::Event do
  let(:service_instance) { double(Moleculer::Service::Base, some_method: true) }
  let(:service) { class_double(Moleculer::Service::Base, new: service_instance, node: node) }
  let(:node) { instance_double(Moleculer::Node) }

  subject { Moleculer::Service::Event.new("event.name", service, :some_method, some: "options") }

  describe "#execute" do
    it "sends the method with the provided argument" do
      subject.execute(foo: "bar")
      expect(service_instance).to have_received(:some_method).with(foo: "bar")
    end
  end

  describe "#node" do
    it "returns the service's node" do
      expect(subject.node).to eq node
    end
  end

  describe "#as_json" do
    it "returns the correct json for the event" do
      expect(subject.as_json).to eq(name: subject.name)
    end
  end
end
