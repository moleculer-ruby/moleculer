RSpec.describe Moleculer::Registry do
  let(:broker) { instance_double(Moleculer::Broker) }
  subject { Moleculer::Registry.new(broker) }

  describe "#local_node" do
    it "returns the local node" do
      expect(subject.local_node).to be_a Moleculer::Node
      expect(subject.local_node.local?).to be_truthy
    end
  end
end
