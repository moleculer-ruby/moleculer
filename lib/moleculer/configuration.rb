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

        class_eval <<-method
          def #{attribute}
            @#{attribute} ||= default_for("#{attribute}".to_sym)
          end
        method

        instance_eval do
          attr_writer attribute.to_sym
        end
      end
    end

    config_accessor :log_file
    config_accessor :log_level, :debug
    config_accessor :logger do |c|
      logger           = Ougai::Logger.new(c.log_file || STDOUT)
      logger.formatter = Ougai::Formatters::Readable.new("MOL")
      logger.level     = c.log_level
      Moleculer::Support::LogProxy.new(logger)
    end
    config_accessor :heartbeat_interval, 5
    config_accessor :timeout, 5
    config_accessor :transporter, "redis://localhost"
    config_accessor :serializer, :json
    config_accessor :node_id, "#{Socket.gethostname.downcase}-#{Process.pid}"
    config_accessor :service_prefix
    config_accessor :rescue_action

    attr_accessor :broker

    def initialize(options={})
      options.each do |option, value|
        send("#{option}=".to_sym, value)
      end
    end

    def services
      @services ||= ServiceList.new(self)
    end

    def services=(array)
      @services = ServiceList.new(self)
      array.each { |s| @services << s}
    end

    private

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
