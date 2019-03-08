require "concurrent"
require "securerandom"
require "socket"

require "moleculer/broker"
require "moleculer/context"
require "moleculer/packet"
require "moleculer/service"
require "moleculer/support"
require "moleculer/version"
require "moleculer/node"

module Moleculer
  extend self
  PROTOCOL_VERSION = "3".freeze

  attr_writer :node_id,
              :logger,
              :log_level,
              :log

  def config(&block)
    yield self
  end
  #   class << self
  #
  #     def broker
  #       @broker ||= Broker.new(node_id: self.node_id, transporter: self.transporter, namespace: self.namespace)
  #     end
  #
  #     def call(action_name, params, options={}, &block)
  #       broker.call(action_name, params, options, &block)
  #     end
  #
  #     def emit(event_name, payload)
  #       broker.emit(event_name, payload)
  #     end
  #
  #     def start
  #       broker.start
  #     end
  #
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

  def create_logger(tag = nil)
    unless @base_logger
      @base_logger = Logger.new(@log || STDOUT)
      @base_logger.level = @log_level || Logger::Severity::DEBUG
    end
    Moleculer::Support::TaggedLogger.new(@base_logger, tag)
  end

  #     def timeout
  #       @timeout = 5
  #     end
  #
  #     def transporter
  #       @transporter || "redis://localhost"
  #     end
  #
  #     def register_service(klass)
  #       services << klass
  #     end
  #
  #   end
end
