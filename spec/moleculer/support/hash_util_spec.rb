# frozen_string_literal: true

RSpec.describe Moleculer::Support::HashUtil do
  subject { Moleculer::Support::HashUtil }

  describe "::fetch" do
    let!(:obj) do
      double
    end

    let(:hash) do
      {
        "test_one" => 1,
        "testTwo" => 2,
        testThree: 3,
        test_four: 4,
        obj => 5,
      }
    end

    it "fetches correctly" do
      expect(subject.fetch(hash, :testOne)).to eq 1
      expect(subject.fetch(hash, :test_two)).to eq 2
      expect(subject.fetch(hash, "test_three")).to eq 3
      expect(subject.fetch(hash, "testFour")).to eq 4
      expect(subject.fetch(hash, obj)).to eq 5
      expect(subject.fetch(hash, :not_there, "foo")).to eq "foo"
    end
  end

  describe "::stringify_keys" do
    it "recursively stringifies keys" do
      expect(subject.stringify_keys(foo: { bar: "baz" })).to eq("foo" => { "bar" => "baz" })
    end
  end
end
