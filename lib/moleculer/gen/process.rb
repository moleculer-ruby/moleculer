# frozen_string_literal: true

module Moleculer
  module Gen
    ##
    # Imeplements an Erlang style GenServer like Process based on `Ractor`
    class Process
      ##
      # @private
      class Implementation
        def initialize(process)
          @process = process
          @running = true
        end

        def running?
          running
        end

        def call(*args)
          ractor.send([:call, *args])
          ractor.take
        end

        def cast(*args)
          ractor.send([:cast, *args])
        end

        def start
          @ractor = Ractor.new(self, process) do |impl, p|
            impl.handle_message(p, Ractor.receive) while impl.running?
          end
        end

        # use dependency injection for `process` instead of relying on the instance
        # variable as this is called within the `Ractor`
        def handle_message(process, (method, *message))
          case method
          when :call
            Ractor.yield process.handle_call(message)
          when :cast
            process.handle_cast(message)
          end
        end

        private

        attr_reader :process, :running, :ractor
      end

      def self.new(*args)
        Implementation.new(super(*args))
      end

      private

      attr_reader :implementation

      def handle_call(**args)
        raise NotImplementedError
      end

      def handle_cast(**args)
        raise NotImplementedError
      end
    end
  end
end
