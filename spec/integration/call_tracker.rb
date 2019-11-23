# frozen_string_literal: true

# @private
module CallTracker
  extend self
  attr_reader :events_called

  def event_called(name)
    @events_called       ||= {}
    @events_called[name] ||= 0
    @events_called[name]  += 1
  end

  def reset
    @events_called = {}
  end
end
