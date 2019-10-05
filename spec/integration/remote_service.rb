# frozen_string_literal: true

# @private
class RemoteService < Moleculer::Service::Base
  service_name "remote"
  action :test, :remote_action

  def remote_action(_)
    { result: "remote action result" }
  end
end
