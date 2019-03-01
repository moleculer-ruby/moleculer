RSpec.describe Moleculer::Service do
  subject {
    Class.new do
      include Moleculer::Service

      def test_method
        return "test_method"
      end
    end
  }

  it "is a singleton" do
    expect { subject.new }.to raise_error(NoMethodError)
  end

  it "forwards method calls to the singleton instance" do
    expect(subject.test_method).to eq "test_method"
  end



end
