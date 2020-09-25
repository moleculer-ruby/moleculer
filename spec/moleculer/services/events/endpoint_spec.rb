# frozen_string_literal: true

require_relative "../endpoint_helper"

RSpec.describe Moleculer::Service::Events::Endpoint do
  it_behaves_like Moleculer::Service::Endpoint do
    let(:callable_class) { Moleculer::Service::Events::Endpoint }
    let(:params) do
      {
        group: "test",
      }
    end
    let(:expected_schema) do
      {
        name: "test",
      }
    end
  end
end
