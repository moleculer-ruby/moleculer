RSpec.describe Moleculer::Node do
  describe "local node" do
    subject { Moleculer::Node.new(node_id: "test-node") }
    describe "#local?" do
      subject { Moleculer::Node }

      it "should return true when local is set to true" do
        expect(subject.new(local: true, node_id: "test-node").local?).to eq true
      end

      it "should return when local is set to false" do
        expect(subject.new(node_id: "test-node").local?).to eq false
      end
    end

    describe "#node_id" do
      it "sets the node_id appropriately" do
        expect(subject.node_id).to eq "test-node"
      end
    end

    describe "#register_service" do
      let(:service) { double(Moleculer::Service::Base, name: "test-service") }
      it "adds the service to the node with its provided name" do
        subject.register_service(service)
        expect(subject.services["test-service"]).to eq service
      end

      describe "register_service_callback is defined" do
        let(:callback) { spy("callback") }
        subject do
          Moleculer::Node.new(
            node_id: "test-node",
            register_service_callback: ->(node, service) { callback.do_things(node, service) },
          )
        end

        it "calls the register service callback if it is defined" do
          subject.register_service(service)
          expect(callback).to have_received(:do_things).with(subject, service)
        end
      end
    end
  end
end
