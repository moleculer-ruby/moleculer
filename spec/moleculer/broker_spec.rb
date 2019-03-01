require "socket"
RSpec.describe Moleculer::Broker do
  subject { Moleculer::Broker.new(namespace: "test", transporter: "redis://localhost") }

  describe "#new" do
    it "sets the default the node id" do
      expect(subject.node_id).to eq "#{Socket.gethostname.downcase}-#{Process.pid}"
    end

    it "selects the correct transporter" do
      expect(subject.transporter).to be_a(Moleculer::Transporters::Redis)
    end

    it "sets the logger" do
      expect(subject.logger).to be_an_instance_of(Logger)
    end

    it "sets the namespace correctly" do
      expect(subject.namespace).to eq "test"
    end
  end
end
