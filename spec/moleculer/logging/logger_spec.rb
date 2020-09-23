# frozen_string_literal: true

require "console"

RSpec.describe Moleculer::Logging::Logger do
  subject do
    Moleculer::Logging::Logger.new(self)
  end

  let(:logger) { double(Console::Logger) }

  before :each do
    allow(subject).to receive(:base).and_return(logger)
  end

  %w[info debug warn error fatal].each do |level|
    describe "##{level}" do
      it "should write to the base logger" do
        expect(logger).to receive(level).with(self)
        subject.public_send(level, "test")
      end
    end
  end
end
