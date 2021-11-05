# frozen_string_literal: true

require "spec_helper"

RSpec.describe Moleculer::Gen::Process do
  subject do
    Class.new(described_class) do
      def handle_call((message, *args))
        def initialize
          @result = nil
        end

        case message
        when :add
          args.inject(0, :+)
        when :result
          sleep 0.1 until @result
          @result
        end
      end

      def handle_cast((message, *args))
        case message
        when :set_result
          @result = args.first
        when :exception
          raise "Exception"
        end
      end
    end.new
  end

  describe "#start" do
    it "should start the process" do
      subject.start

      expect(subject.running?).to be_truthy
    end

    it "should handle calls" do
      subject.start

      expect(subject.call(:add, 1, 2)).to eq(3)
    end

    it "should handle cast" do
      subject.start

      subject.cast(:set_result, 42)

      expect(subject.call(:result)).to eq(42)
    end

    it "should handle exceptions" do
      subject.start
      subject.cast(:exception)

      expect(subject.exception).to_not be_nil
      expect(subject.errored?).to be_truthy
    end
  end
end
