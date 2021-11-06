# frozen_string_literal: true

module Moleculer
  ##
  # A basic event emitter.
  class EventEmitter
    def initialize
      @events = {}
    end

    def on(event, &block)
      @events[event] ||= []
      @events[event] << block
    end

    def emit(event, *args)
      return unless @events[event]

      @events[event].each do |block|
        block.call(*args)
      end
    end
  end
end
