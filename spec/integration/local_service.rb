# frozen_string_literal: true

# @private
class LocalService < Moleculer::Service::Base
  service_name "local"
  action :test, :local_action

  def local_action(_)
    { result: "local action result" }
  end
end
