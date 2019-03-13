require_relative "../../lib/moleculer/transporters"

RSpec.describe Moleculer::Transporters do
  subject { Moleculer::Transporters }
  describe "::for" do
    let(:broker) { instance_double(Moleculer::Broker) }

    it "correctly returns a Redis transporter" do
      expect(subject.for("redis://localhost", broker)).to be_a Moleculer::Transporters::Redis
    end
  end
end