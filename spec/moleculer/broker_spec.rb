require "socket"
RSpec.describe Moleculer::Broker do
  subject { Moleculer::Broker.new }

  describe "#start" do
    describe "with local services" do
      let(:service_1) { class_double(Moleculer::Service::Base)}
      let(:service_2) { class_double(Moleculer::Service::Base)}
      let(:registry)  { subject.instance_variable_get(:@registry)}

      it "calls register local services with all listed local services" do
        allow(Moleculer).to receive(:services).and_return([
          service_1,
          service_2,
                                                          ])

        allow(registry).to receive(:register_local_service)
        subject.start

        expect(registry).to have_received(:register_local_service).with(service_1)
        expect(registry).to have_received(:register_local_service).with(service_2)
      end
    end
  end
end
