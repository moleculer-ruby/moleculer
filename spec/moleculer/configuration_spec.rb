# frozen_string_literal: true

RSpec.describe Moleculer::Configuration do
  subject { Moleculer::Configuration.new }
  shared_context "environment configurable" do |key, default, set, env|
    describe "default" do
      it "returns the default value" do
        expect(subject.send(key)).to eq default
      end
    end

    describe "set value" do
      before :each do
        subject.send(:"#{key}=", set)
      end

      it "returns the set value" do
        expect(subject.send(key)).to eq set
      end
    end

    describe "env value" do
      before :each do
        ENV["MOLECULER_#{key.upcase}"] = env.to_s
        load File.expand_path("../../lib/moleculer/configuration.rb", __dir__)
      end

      after :each do
        ENV.delete("MOLECULER_#{key.upcase}")
        load File.expand_path("../../lib/moleculer/configuration.rb", __dir__)
      end

      it "returns the environment value" do
        expect(subject.send(key)).to eq env
      end
    end
  end

  describe "#log_file" do
    include_examples "environment configurable", :log_file, "/dev/null", "otherfile.log", "otherotherfile.log"
  end

  describe "#log_level" do
    include_examples "environment configurable", :log_level, :debug, :trace, :info
  end

  describe "#transporter" do
    include_examples "environment configurable", :transporter, "redis://localhost", "redis://test1", "redis::/test2"
  end

  describe "#timeout" do
    include_examples "environment configurable", :timeout, 5, 2, 3
  end

  describe "#hearbeat_interfval" do
    include_examples "environment configurable", :heartbeat_interval, 5, 2, 3
  end

  describe "#handle_error" do
    let(:grandparent) { Class.new(StandardError) }
    let(:parent) { Class.new(grandparent) }
    let(:child) { Class.new(parent) }

    before :each do
      allow(subject.logger).to receive(:error)
      subject.rescue_from(ArgumentError) do |e|
        subject.logger.error(e)
      end
      subject.rescue_from(child) do |e|
        subject.logger.error(e)
        raise e
      end
      subject.rescue_from(parent) do |e|
        subject.logger.error(e)
        raise e
      end
      subject.rescue_from(grandparent) do |e|
        subject.logger.error(e)
        raise e
      end
    end

    it "should log out standard error" do
      err = StandardError.new("test")
      subject.handle_error(err)
      expect(subject.logger).to have_received(:error).with(err)
    end

    it "should handle custom errors when defined" do
      err = ArgumentError.new("test")
      subject.handle_error(ArgumentError.new("test"))
      expect(subject.logger).to have_received(:error).with(err)
    end

    it "should cascade errors up the parent tree when children raise" do
      err = child.new("test")
      subject.handle_error(err)
      expect(subject.logger).to have_received(:error).with(err).exactly(4).times
    end

    it "should not try and handle an exception if the exception handler raises at StandardError" do
      subject.rescue_from(StandardError) do |e|
        raise e
      end

      err = StandardError.new("test")
      expect { subject.handle_error(err) }.to raise_error(err)
    end
  end
end
