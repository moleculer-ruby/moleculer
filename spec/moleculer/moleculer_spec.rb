RSpec.describe Moleculer do
  let(:broker) { instance_double(Moleculer::Broker, ensure_running: true, call: true) }

  describe "#broker" do
    it "returns a new instance of the broker when first called" do
      expect(subject.broker).to be_a(Moleculer::Broker)
    end

    it "returns the same instance of the broker every time it is called" do
      broker = subject.broker
      expect(subject.broker).to eq broker
    end
  end

  describe "#call" do
    before :each do
      allow(subject).to receive(:broker).and_return(broker)
    end

    it "ensures the broker is running" do
      subject.call("an_action")
      expect(broker).to have_received(:ensure_running)
    end

    it "passes the call arguments to the broker #call method" do
      subject.call(:an_action, foo: "bar")
      expect(broker).to have_received(:call).with("an_action", foo: "bar")
    end

    it "passes options to the broker #call function" do
      subject.call(:an_action, { foo: "bar" }, node_id: "node", meta: { meta: true }, timeout: 5)
      expect(broker).to have_received(:call)
        .with("an_action", { foo: "bar" }, node_id: "node", meta: { meta: true }, timeout: 5)
    end
  end

  describe "#config" do

  end
end
