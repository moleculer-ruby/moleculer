# frozen_string_literal: true

require "async/container"

module Moleculer
  class Controller < Async::Container::Controller
    def setup(task); end

    private

    def create_container
      Async::Container::Threaded
    end
  end
end
