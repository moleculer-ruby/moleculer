# frozen_string_literal: true

require_relative "../endpoint_helper"

RSpec.describe Moleculer::Service::Actions::Endpoint do
  it_behaves_like Moleculer::Service::Endpoint do
    let(:callable_class) { Moleculer::Service::Actions::Endpoint }
    let(:params) do
      {
        cache:   false,
        timeout: 0,
        method:  :test,
      }
    end
    let(:expected_schema) do
      {
        name:     "service.test",
        raw_name: "test",
        cache:    false,
        params:   {},
        metrics:  {
          meta:   false,
          params: false,
        },
      }
    end
  end
end
