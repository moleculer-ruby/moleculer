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
    include_examples "environment configurable", :log_file, nil, "otherfile.log", "otherotherfile.log"
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
end
