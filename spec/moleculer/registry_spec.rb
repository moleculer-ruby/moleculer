RSpec.describe Moleculer::Registry do
  let(:broker) { instance_double(Moleculer::Broker) }
  subject { Moleculer::Registry.new(broker) }

  describe "::register_node" do
    let(:local_node) do
      instance_double(Moleculer::Node::Local,
                      local?: true,
                      id:     "local-node",
                      action: [])
    end

    it "registered a local_node as the local node" do
      subject.register_node(local_node)
      expect(subject.instance_variable_get(:@local_node)).to eq local_node
    end

    it "throws an error if a local_node is registered more than once" do
      subject.register_node(local_node)
      expect { subject.register_node(local_node) }.to raise_error(Moleculer::Errors::LocalNodeAlreadyRegistered)
    end
  end
end
