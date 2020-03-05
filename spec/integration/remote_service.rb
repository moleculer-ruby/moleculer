# frozen_string_literal: true

require_relative "call_tracker"

# @private
class RemoteService < Moleculer::Service::Base
  service_name "remote"
  action "test", :remote_action
  action "test_with_meta", :remote_action_with_meta
  action "test_with_timeout", :remote_test_with_timeout
  action "test_with_retries", :remote_test_with_retries

  event  "test-remote-event", :remote_event

  attr_reader :event_fired

  def initialize(*args)
    super
    @retries = 0
  end

  def remote_action(_)
    { result: "remote action result" }
  end

  def remote_action_with_meta(ctx)
    { result: ctx.meta }
  end

  def remote_test_with_timeout(_)
    sleep 0.2
  end

  def remote_test_with_retries(_)
    @retries += 1
    raise Moleculer::Errors::RetryableError.new("An Error", 404, "RetryableError", {}) if @retries < 5

    { retries: @retries }
  end

  def remote_event(_)
    CallTracker.event_called("test-remote-event")
  end
end
