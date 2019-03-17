RSpec.describe Moleculer::Service::Action::Local do
  subject { Moleculer::Action::Local }
  let!(:service) {
    Class.new(Moleculer::Service::Base) do
      action :test_broken_response, :test_broken_response
      action :test_valid_response, :test_valid_response

      def test_broken_response(_)
        "not a hash"
      end

      def test_valid_response(_)
        {}
      end
    end
  }

  let(:context) {
    Moleculer::Context.new(
      double("broker"),
      subject,
      SecureRandom.uuid,
      {},
      {}
    )
  }

  describe "#execute" do

    describe "invalid action" do
      subject { service.actions[:test_broken_response] }

      it "raises an InvalidActionResponse when response is not a Hash" do
        expect { subject.execute(context) }.to raise_error Moleculer::Errors::InvalidActionResponse
      end
    end

    describe "valid action" do
      subject { service.actions[:test_valid_response] }

      it "does not raise an InvalidActionResponse when a Hash is returned" do
        expect { subject.execute(context) }.to_not raise_error
      end
    end
  end
end
