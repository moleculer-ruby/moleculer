module Moleculer
  ##
  # Handles Moleculer configuration
  # @private
  class Configuration
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

      def config_reader(attribute, value)
        class_eval <<-method
          def #{attribute}
            @#{attribute} ||= #{value}
            @#{attribute} 
          end
        method
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
    config_reader :services, []

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
