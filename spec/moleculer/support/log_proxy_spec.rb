# frozen_string_literal: true

RSpec.shared_examples "basic logger" do
  subject { Moleculer::Support::LogProxy.new(logger) }
  let(:prefix) { "" }
  let(:log_line) { "#{prefix} test #{{ foo: 'bar' }}".strip }

  it "passes fatal to the logger" do
    subject.fatal("test", foo: "bar")
    expect(logger).to have_received(:fatal).with(log_line)
  end

  it "passes error to the logger" do
    subject.error("test", foo: "bar")
    expect(logger).to have_received(:error).with(log_line)
  end

  it "passes warn to the logger" do
    subject.warn("test", foo: "bar")
    expect(logger).to have_received(:warn).with(log_line)
  end

  it "passes info to the logger" do
    subject.info("test", foo: "bar")
    expect(logger).to have_received(:info).with(log_line)
  end

  it "passes debug to the logger" do
    subject.debug("test", foo: "bar")
    expect(logger).to have_received(:debug).with(log_line)
  end
end

RSpec.describe Moleculer::Support::LogProxy do
  describe "trace logger" do
    it_should_behave_like "basic logger" do
      let(:logger) do
        instance_double(Ougai::Logger, fatal: true, error: true, warn: true, info: true, debug: true, trace: true)
      end

      it "passes trace to the logger" do
        subject.trace("test", foo: "bar")
        expect(logger).to have_received(:trace).with("#{prefix}test {:foo=>\"bar\"}")
      end
    end
  end

  describe "ruby logger" do
    it_should_behave_like "basic logger" do
      let(:logger) { instance_double(::Logger, fatal: true, error: true, warn: true, info: true, debug: true) }

      it "passes trace as debug to the logger" do
        subject.trace("test", foo: "bar")
        expect(logger).to have_received(:debug).with("#{prefix}test {:foo=>\"bar\"}")
      end
    end
  end

  describe "prefixed child logger" do
    it_should_behave_like "basic logger" do
      let(:logger) { instance_double(::Logger, fatal: true, error: true, warn: true, info: true, debug: true) }
      let(:prefix) { "child ->" }
      subject { Moleculer::Support::LogProxy.new(logger).get_child(prefix) }
    end
  end

  describe "#level" do
    subject { Moleculer::Support::LogProxy.new(instance_double(::Logger, level: 1)) }
    it "returns the sub logger level" do
      expect(subject.level).to eq(1)
    end
  end
end
