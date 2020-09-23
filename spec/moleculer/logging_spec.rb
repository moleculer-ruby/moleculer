# frozen_string_literal: true

RSpec.describe Moleculer::Logging do
  subject do
    Class.new do
      include Moleculer::Logging
    end.new
  end

  describe "#logger" do
    it "returns a Moleculer::Logging::Logger instance" do
      expect(subject.send(:logger)).to be_a(Moleculer::Logging::Logger)
    end
  end
end
