# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Moleculer::Service::Action do
  subject do
    Moleculer::Service::Action.new(
      service: double(Moleculer::Service::Base),
      name:    "test",
      handler: :some_action,
      cache:   false,
      before:  nil,
      after:   nil,
      error:   nil,
      params:  {
        name: { type: "string" },
        age:  { type: "number" },
      },
    )
  end

  describe "#to_info" do
    it "returns a hash representing the action" do
      expect(subject.to_info).to eq(name:   "test",
                                    params: {
                                      name: { type: "string" }, age: { type: "number" }
                                    })
    end
  end
end
