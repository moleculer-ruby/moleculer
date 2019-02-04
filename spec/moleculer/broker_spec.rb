require "socket"
RSpec.describe Moleculer::Broker do
  describe "#new" do
    it "sets the default the node id" do
      expect(subject.node_id).to eq "#{Socket.gethostname.downcase}-#{Process.pid}"
    end

    it "selects the correct transporter" do
      expect(subject.transporter).to be_a(Moleculer::Transporters::Redis)
    end
  end
end
