# frozen_string_literal: true

require_relative "callable_helper"

RSpec.describe Moleculer::Service::Event do
  it_behaves_like Moleculer::Service::Callable do
    let(:callable_class) { Moleculer::Service::Event }
    let(:params) do
      {
        group: "test"
      }
    end
  end
end
