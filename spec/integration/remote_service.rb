# frozen_string_literal: true

require_relative "call_tracker"

# @private
class RemoteService < Moleculer::Service::Base
  service_name "remote"
  action :test, :remote_action
  event  "test-remote-event", :remote_event

  attr_reader :event_fired

  def initialize(*args)
    super
    @event_fired = 0
  end

  def remote_action(_)
    { result: "remote action result" }
  end

  def remote_event(_)
    CallTracker.event_called("test-remote-event")
  end
end
