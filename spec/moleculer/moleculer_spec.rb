# frozen_string_literal: true

RSpec.describe Moleculer do
  let(:broker) do
    instance_double(Moleculer::Broker,
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

  describe "#configure" do
    after :each do
      Moleculer.send(:remove_instance_variable, :@config)
    end

    describe "set configuration" do
      before :each do
        subject.configure do |c|
          c.node_id            = "test"
          c.log_level          = :trace
          c.serializer         = :yaml
          c.timeout            = 100
          c.transporter        = "some_transporter"
          c.service_prefix     = "service"
          c.heartbeat_interval = 10
          c.services << Moleculer::Service::Base
        end
      end

      it "should allow moleculer to be configured" do
        expect(subject.config.node_id).to include("test")
        expect(subject.config.logger.level).to eq Ougai::Logging::Severity::TRACE
        expect(subject.config.serializer).to eq :yaml
        expect(subject.config.timeout).to eq 100
        expect(subject.config.transporter).to eq "some_transporter"
        expect(subject.config.service_prefix).to eq "service"
        expect(subject.config.heartbeat_interval).to eq 10
        expect(subject.config.services).to include(Moleculer::Service::Base)
      end
    end

    it "should have the correct defaults" do
      expect(subject.config.node_id).to include(Socket.gethostname.downcase)
      expect(subject.config.logger.level).to eq Ougai::Logger::Severity::DEBUG
      expect(subject.config.serializer).to eq :json
      expect(subject.config.timeout).to eq 5
      expect(subject.config.transporter).to eq "redis://localhost"
      expect(subject.config.service_prefix).to be_nil
      expect(subject.config.heartbeat_interval).to eq 5
      expect(subject.config.services.length).to eq 0
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
      expect(subject.config.logger).to be_a(Moleculer::Support::LogProxy)
    end

    it "sets the default log level correctly" do
      expect(subject.config.logger.level).to eq Ougai::Logging::Severity::DEBUG
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
