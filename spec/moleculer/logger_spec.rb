# frozen_string_literal: true

require_relative "../../lib/moleculer/logger"

RSpec.describe Moleculer::Logger do
  subject do
    Class.new do
      include Moleculer::Logger
    end
  end

  describe "#get_logger" do
    it "returns the tagged logger" do
      expect { subject.new.send(:get_logger, "test", "ing").debug("foo") }
        .to output(/D, \[.+ #\d+\] \[test\/ing\] DEBUG \-\- : foo/).to_stdout_from_any_process
    end
  end
end
