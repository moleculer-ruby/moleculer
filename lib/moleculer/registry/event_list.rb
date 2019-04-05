require_relative "base_list"

class Moleculer::Registry::EventList < BaseList

  ##
  # Adds an event to the given group.
  #
  # @param event [Moleculer::Node::Event] the event to add
  # @param group [String] the group to which to add the event
  def add(event, group)
    @list[event.name] = event
    @groups ||= {}
    @groups[group] ||= []
    @groups[group] << event
  end

  # TODO: Add proper load balancing strategy here
  def get_balanced_endpoints(pattern, groups)
    matched_events = @list.keys.map { |event_name| match(event_name, pattern) }
    matched_events.map { |event| event.node }
  end


  private

  # TODO: add pattern and regex based matching
  def match(text, pattern)
    text == pattern
  end

end
