# frozen_string_literal: true

RSpec.describe Moleculer::Broker::Base do
  subject { Moleculer::Broker::Base.new(request_timeout: 0.01) }

  let(:action) do
    double(
      Moleculer::Service::Action,
      node_id: subject.node_id,
      call:    true,
      name:    "action",
    )
  end

  before :each do
    allow(subject.registry).to receive(:get_action_endpoint)
      .and_return(action)
  end

  describe "#call" do
    context "normal action call" do
      before :each do
        allow(action).to receive(:call) do |context|
          subject
            .add_response(double("response", payload: { id: context.request_id, success: true, data: { success: true } }))
        end

        it "calls the action" do
          expect(subject.call("test")).to include(success: true)
        end
      end
    end

    context "timeout error" do
      it "clears the context and re-raises" do
        expect { subject.call("test") }.to raise_exception(Moleculer::Errors::RequestTimeoutError)
      end
    end

    context "any other error" do
      before :each do
        allow(action).to receive(:call) do
          raise StandardError, "broken!"
        end
      end

      it "clears the context and re-raises" do
        expect { subject.call("test") }.to raise_exception(StandardError)
      end
    end

    context "retries" do

      context "non retryable errors" do
        before :each do
          allow(action).to receive(:call) do
            raise StandardError, "test"
          end
        end

        it "does not retry" do
          expect(action).to receive(:call).exactly(1).times
          expect { subject.call("test") }.to raise_exception(StandardError)

        end
      end

      context "retryable errors" do
        before :each do
          allow(action).to receive(:call) do
            raise Moleculer::Errors::RequestTimeoutError, action
          end
        end

        context "default retry value" do
          subject { Moleculer::Broker::Base.new(request_timeout: 0.01, retry_policy: { retries: 5 }) }

          it "retries the correct number of times" do
            expect(action).to receive(:call).exactly(5).times
            expect { subject.call("test") }.to raise_exception(Moleculer::Errors::RequestTimeoutError)
          end
        end

        context "explicit retries" do
          subject { Moleculer::Broker::Base.new(request_timeout: 0.01) }

          it "retries the correct number of times" do
            expect(action).to receive(:call).exactly(10).times
            expect { subject.call("test", nil, retries: 10) }
              .to raise_exception(Moleculer::Errors::RequestTimeoutError)
          end
        end
      end

      context "response returns an error" do
        before :each do
          allow(action).to receive(:call) do |context|
            subject
              .add_response(double("response", payload: {
                id:      context.request_id,
                success: false,
                error:   { name: "AnError" },
              }))
          end
        end

        it "raises the result of the error recreation" do
          error = StandardError.new
          expect(Moleculer::Errors).to receive(:recreate_error).with(hash_including(name: "AnError")) do
            error
          end

          expect { subject.call("test") }.to raise_error(error)
        end
      end
    end
  end

  describe "#process_response" do
    it "returns the data within the response" do
      expect(subject.process_response(success: true, data: { foo: "bar" })).to include(foo: "bar")
    end
  end

  describe "#send_action" do
    let(:transit) { subject.instance_variable_get(:@transit) }
    let(:endpoint) { double("Endpoint") }
    let(:context) { double("Context") }

    it "sends the action to the transit" do
      expect(transit).to receive(:send_action).with(endpoint, context).and_return(true)

      subject.send_action(endpoint, context)
    end
  end
end
