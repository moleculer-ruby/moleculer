RSpec.describe Moleculer::Support::Hash do
  describe "class methods" do
    subject { Moleculer::Support::Hash }

    describe "::new" do
      it "symbolizes the keys and creates a new hash object" do
        expect(subject[:test1]).to eq "test1"
      end
    end

    describe "::[]" do
      it "creates the hash after symbolizing the keys" do
        expect(subject[[["a", 1]]][:a]).to eq 1
      end
    end

    describe "::from_hash" do
      it "converts to a Moleculer::Support::Hash" do
        expect(subject.from_hash({})).to be_a subject
      end
    end
  end
end
