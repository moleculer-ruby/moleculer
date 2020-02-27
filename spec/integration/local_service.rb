# frozen_string_literal: true

# @private
class LocalService < Moleculer::Service::Base
  service_name "local"
  action "test", :local_action
  action "test_with_meta", :local_action_with_meta
  event "test-local-event", :local_event

  def local_action(_)
    { result: "local action result" }
  end

  def local_action_with_meta(ctx)
    { result: ctx.meta }
  end

  def local_event(_)
    CallTracker.event_called("test-local-event")
  end
end
