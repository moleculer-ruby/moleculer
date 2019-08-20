RSpec.describe Moleculer::Service::Event do
  let(:config) { Moleculer::Configuration.new }
  let(:broker) { instance_double(Moleculer::Broker, config: config) }

  subject do
    Moleculer::Service::Event.new(
      "event.name",
      service,
      :some_method,
      some: "options",
      rescue_event: nil
    )
  end

  describe "#execute" do
    subject { Moleculer::Service::Event.new("test", service, :test_event) }

    describe "exception handling" do
      let(:errors) { [] }
      let(:service) do
        Class.new(Moleculer::Service::Base) do
          def test_event(_)
            raise StandardError, "test error"
          end
        end
      end

      before :each do
        allow(broker.config.logger).to receive(:error)
      end

      it "handles the error using the rescue_event proc" do
        subject.execute({}, broker)
        expect(broker.config.logger).to have_received(:error).with(instance_of(StandardError))
      end
    end
  end
end
