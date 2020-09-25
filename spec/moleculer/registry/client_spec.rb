# frozen_string_literal: true

RSpec.describe Moleculer::Registry::Client do
  describe "::from_schema" do
    let(:schema) do
      {
        type:         "ruby",
        version:      "0.4.0",
        lang_version: "2.7.1",
      }
    end

    subject { Moleculer::Registry::Client }

    it "should create an instance from the schema" do
      instance = subject.from_schema(schema)
      expect(instance.type).to eq("ruby")
      expect(instance.version).to eq("0.4.0")
      expect(instance.lang_version).to eq("2.7.1")
    end
  end
end
