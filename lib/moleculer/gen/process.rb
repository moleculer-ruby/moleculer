# frozen_string_literal: true

require "securerandom"

module Moleculer
  module Gen
    ##
    # Imeplements an Erlang style GenServer like Process based on `Ractor`
    class Process
      ##
      # @private
      class Implementation
        attr_reader :exception, :status, :uuid

        def initialize(process_class, *args)
          @args          = args
          @process_class = process_class
          @state         = :alive
          @uuid          = SecureRandom.uuid
        end

        def alive?
          @state == :alive
        end

        def errored?
          @state == :error
        end

        def call(*args)
          ractor.send([:call, *args])
          ractor.take
        rescue StandardError => e
          handle_exception(e)
        end

        def cast(*args)
          ractor.send([:cast, *args])
          ractor.take
        rescue StandardError => e
          handle_exception(e)
        end

        def start
          @state  = :alive
          process = process_class.new(*@args)

          @ractor = Ractor.new(self, process) do |impl, p|
            process.on_start
            impl.handle_message(p, Ractor.receive) while impl.running?
            process.on_stop
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
            Ractor.yield true
          end
        end

        private

        attr_reader :process_class, :args, :running, :ractor, :supervisor

        def handle_exception(exception)
          @state     = :error
          @exception = exception

          supervisor.cast([:error, exception])
        end
      end

      def self.new(*args)
        Implementation.new(self, *args)
      end

      ##
      # Called when the `Process` is started
      def on_start; end

      ##
      # Called when the `Process` is stopped
      def on_stop; end

      ##
      # Handle `call` messages
      #
      # @param args [any] arguments passed to the `call` message
      def handle_call(**args)
        raise NotImplementedError
      end

      ##
      # Handle `cast` messages
      #
      # @param args [any] arguments passed to the `cast` message
      def handle_cast(**args)
        raise NotImplementedError
      end

      private

      attr_reader :implementation
    end
  end
end
