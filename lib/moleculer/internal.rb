# frozen_string_literal: true

require_relative "service/base"

module Moleculer
  ##
  # Internal $node service
  class Internal < Service::Base
    name "$node"

    action :list
    action :services
    action :actions
    action :events
    action :health
    action :metrics
    action :options

    def list(_ctx)
      registry.nodes
    end

    def services(_ctx)
      registry.services
    end

    def actions(_ctx)
      registry.actions
    end

    def events(_ctx)
      registry.events
    end

    def health(_ctx)
      broker.healt_status
    end

    def options
      broker.options
    end

    def metrics(_ctx)
      raise Errors::MolculerClientError, "Metrics feature is disabled", 400, "METRICS_DISABLED"
    end

    private

    def registry
      broker.registry
    end
  end
end
