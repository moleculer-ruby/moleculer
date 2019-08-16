# frozen_string_literal: true

module Moleculer
  ##
  # Handles Moleculer configuration
  # @private
  class Configuration
    ##
    # @private
    class ServiceList
      def initialize(configuration)
        @configuration = configuration
        @services      = []
      end

      def <<(service)
        service.broker = @configuration.broker
        @services << service
      end

      def length
        @services.length
      end

      def first
        @services.first
      end

      def map(&block)
        @services.map(&block)
      end

      def each(&block)
        @services.each(&block)
      end

      def include?(service)
        @services.include?(service)
      end
    end

    private_constant :ServiceList

    class << self
      attr_reader :accessors

      private

      def config_accessor(attribute, default = nil, &block)
        @accessors                 ||= {}
        @accessors[attribute.to_sym] = { default: default, block: block }

        class_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{attribute}
            @#{attribute} ||= default_for("#{attribute}".to_sym)
          end
        METHOD

        instance_eval do
          attr_writer attribute.to_sym
        end
      end
    end

    config_accessor :logger do |c|
      logger           = Ougai::Logger.new(c.log_file || STDOUT)
      logger.formatter = Ougai::Formatters::Readable.new("MOL")
      logger.level     = c.log_level
      Moleculer::Support::LogProxy.new(logger)
    end
    config_accessor :log_file, ENV["MOLECULER_LOG_FILE"]
    config_accessor :log_level, ENV["MOLECULER_LOG_LEVEL"]&.to_sym || :debug
    config_accessor :heartbeat_interval, ENV["MOLECULER_HEARTBEAT_INTERVAL"]&.to_i || 5
    config_accessor :timeout, ENV["MOLECULER_TIMEOUT"]&.to_i || 5
    config_accessor :transporter, ENV["MOLECULER_TRANSPORTER"] || "redis://localhost"

    config_accessor :serializer, :json
    config_accessor :node_id, "#{Socket.gethostname.downcase}-#{Process.pid}"

    config_accessor :service_prefix

    attr_accessor :broker

    def initialize(options = {})
      options.each do |option, value|
        send("#{option}=".to_sym, value)
      end
      @rescue_handlers = {}

      rescue_from(StandardError) do |e|
        logger.error(e)
      end
    end

    def services
      @services ||= ServiceList.new(self)
    end

    def services=(array)
      @services = ServiceList.new(self)
      array.each { |s| @services << s }
    end

    ##
    # Add a rescue handler for a specific error. This allows libraries such as airbrake to hook into the error handling
    # flow. When a rescue handler raises, it will look for a rescue handler for the parent class of the thrown error
    # recursively until it reaches StandardError. If the block does not itself raise an error, the error may be
    # swallowed.
    #
    # @param err [Class] the error class to handle
    # @param block [Proc] the block to execute when the error is captured
    def rescue_from(err, &block)
      raise ArgumentError, "block required" unless block_given?
      raise ArgumentError, "error must be a standard error" unless err.ancestors.include?(StandardError)

      @rescue_handlers[err] = block
    end

    ##
    # @private
    def handle_exception(error, parent = nil)
      handler = select_rescue_handler_for(parent || error.class)
      raise error unless handler

      begin
        handler.call(error)
      rescue StandardError => e
        # if the error was re-raised, and a new err was not raised then call the handler for the parent of the original
        # error, otherwise, restart the chain
        return handle_exception(error, parent&.superclass || error.class.superclass) if error == e

        handle_exception(error)
      end
    end

    private

    def select_rescue_handler_for(error_class)
      @rescue_handlers[error_class] || error_class.ancestors.map { |a| @rescue_handlers[a] }.first
    end

    def accessors
      self.class.accessors
    end

    def default_for(attribute)
      accessors[attribute][:default] || (has_block_for?(attribute) ? block_for(attribute).call(self) : nil)
    end

    def block_for(attribute)
      accessors[attribute][:block]
    end

    def has_block_for?(attribute)
      accessors[attribute][:block] && true
    end
  end
end
