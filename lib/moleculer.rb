require "concurrent"
require "securerandom"
require "socket"
require "ougai"

require "moleculer/broker"
require "moleculer/context"
require "moleculer/service"
require "moleculer/support"
require "moleculer/version"
require "moleculer/node"
require "moleculer/serializers"
require "moleculer/packets"

module Moleculer
  extend self
  PROTOCOL_VERSION = "3".freeze

  attr_writer :node_id,
              :logger,
              :log_level,
              :log,
              :serializer

  def config(&block)
    yield self
  end

  def broker
    @broker ||= Broker.new
  end
  #
  #     def emit(event_name, payload)
  #       broker.emit(event_name, payload)
  #     end

  def start
    broker.start
  end

  def run
    broker.run
  end

  def stop
    broker.stop
  end

  #     def namespace
  #       @namespace || ""
  #     end
  #
  def node_id
    @node_id ? "#{@node_id}-#{Process.pid}" : "#{Socket.gethostname.downcase}-#{Process.pid}"
  end

  def services
    @services ||= []
  end

  def logger
    unless @logger
      @logger = Ougai::Logger.new(@log || STDOUT)
      @logger.formatter = Ougai::Formatters::Readable.new("MOL")
      @logger.level = @log_level || :trace
    end
    @logger
  end

  def serializer
    @serializer ||= :json
  end

  #     def timeout
  #       @timeout = 5
  #     end
  #
  def transporter
    @transporter || "redis://localhost"
  end
  #
  #     def register_service(klass)
  #       services << klass
  #     end
  #
  #   end
end
