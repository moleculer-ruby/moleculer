RSpec.describe Moleculer::Service::Event::Local do
  subject { Moleculer::Service::Event::Local }
  let!(:service) do
    Class.new(Moleculer::Service::Base) do
      event :test_valid_event, :test_valid_event

      def test_valid_event(_payload)
        true
      end
    end
  end

  describe "#execute" do
    describe "valid response" do
      subject { service.events[:test_valid_event] }

      it "does not raise an InvalidEventResponse when a Hash is returned" do
        expect { subject.execute() }.to_not raise_error
      end
    end
  end
end
