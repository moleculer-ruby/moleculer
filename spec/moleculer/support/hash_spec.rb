RSpec.describe Moleculer::Support::Hash do
  subject {
    hash = Moleculer::Support::Hash.new
    hash["test1"] = "test1"
    hash
  }

  describe "::new" do
    it "symbolizes the keys and creates a new hash object" do
      expect(subject[:test1]).to eq "test1"
    end
  end
end
