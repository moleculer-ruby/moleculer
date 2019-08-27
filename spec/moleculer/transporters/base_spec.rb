# frozen_string_literal: true

require_relative "../../../lib/moleculer/transporters/base"

RSpec.describe Moleculer::Transporters::Base do
  subject { Moleculer::Transporters::Base.new(Moleculer::Configuration.new) }

  shared_examples "interface" do
    it "raises NotImlementedError" do
      expect { subject.send(method) }.to raise_error(NotImplementedError)
    end
  end

  describe "#start" do
    let(:method) { :start }

    it_should_behave_like "interface"
  end

  describe "#stop" do
    let(:method) { :start }

    it_should_behave_like "interface"
  end

  describe "#publish" do
    let(:method) { :start }

    it_should_behave_like "interface"
  end

  describe "#subscribe" do
    let(:method) { :start }

    it_should_behave_like "interface"
  end
end
