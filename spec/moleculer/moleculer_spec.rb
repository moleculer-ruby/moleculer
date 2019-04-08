RSpec.describe Moleculer do
  let(:broker) do
    instance_double(Moleculer::Broker,
                    ensure_running:    true,
                    call:              true,
                    emit:              true,
                    start:             true,
                    run:               true,
                    stop:              true,
                    wait_for_services: true)
  end

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
    # Necessary to clean up configuration so that it doesn't effect other tests
    before :each do
      Moleculer.send(:remove_instance_variable, :@logger) if Moleculer.send(:instance_variable_get, :@logger)
    end

    after :each do
      %w[node_id log_level serializer heartbeat_interval services timeout transporter service_prefix logger].each do |v|
        if Moleculer.send(:instance_variable_get, "@#{v}".to_sym)
          Moleculer.send(:remove_instance_variable, "@#{v}".to_sym)
        end
      end
    end

    it "should allow moleculer to be configured" do
      subject.config do |c|
        c.node_id        = "test"
        c.log_level      = :trace
        c.serializer     = :yaml
        c.timeout        = 100
        c.transporter    = "some_transporter"
        c.service_prefix = "service"
        c.heartbeat_interval = 10
        c.services << Moleculer::Service::Base
      end

      expect(subject.node_id).to include("test")
      expect(subject.logger.level).to eq Ougai::Logging::Severity::TRACE
      expect(subject.serializer).to eq :yaml
      expect(subject.timeout).to eq 100
      expect(subject.transporter).to eq "some_transporter"
      expect(subject.service_prefix).to eq "service"
      expect(subject.heartbeat_interval).to eq 10
      expect(subject.services).to include(Moleculer::Service::Base)
    end

    it "should have the correct defaults" do
      expect(subject.node_id).to include(Socket.gethostname.downcase)
      expect(subject.logger.level).to eq Ougai::Logger::Severity::DEBUG
      expect(subject.serializer).to eq :json
      expect(subject.timeout).to eq 5
      expect(subject.transporter).to eq "redis://localhost"
      expect(subject.service_prefix).to be_nil
      expect(subject.heartbeat_interval).to eq 5
      expect(subject.services).to eq []
    end
  end

  describe "#emit" do
    before :each do
      allow(subject).to receive(:broker).and_return(broker)
    end

    it "calls broker#emit with the passed params" do
      subject.emit("test", foo: :bar)
      expect(broker).to have_received(:emit).with("test", foo: :bar)
    end
  end

  describe "#logger" do
    it "returns an instance of the logger" do
      expect(subject.logger).to be_a(Moleculer::Support::LogProxy)
    end

    it "sets the default log level correctly" do
      expect(subject.logger.level).to eq Ougai::Logging::Severity::DEBUG
    end
  end

  describe "#run" do
    before :each do
      allow(subject).to receive(:broker).and_return(broker)
    end

    it "calls #run on the broker" do
      subject.run
      expect(broker).to have_received(:run)
    end
  end

  describe "#start" do
    before :each do
      allow(subject).to receive(:broker).and_return(broker)
    end

    it "calls #start on the broker" do
      subject.start
      expect(broker).to have_received(:start)
    end
  end

  describe "#stop" do
    before :each do
      allow(subject).to receive(:broker).and_return(broker)
    end

    it "calls #stop on the broker" do
      subject.stop
      expect(broker).to have_received(:stop)
    end
  end

  describe "#wait_for_services" do
    before :each do
      allow(subject).to receive(:broker).and_return(broker)
    end

    it "calls #wait_for_services on the broker" do
      subject.wait_for_services("test1", "test2")
      expect(broker).to have_received(:wait_for_services).with("test1", "test2")
    end
  end
end
