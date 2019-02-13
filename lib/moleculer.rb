require "moleculer/version"
require "moleculer/broker"
require "moleculer/service"

module Moleculer
  class << self

    def broker
      @broker ||= Broker.new(node_id: self.node_id, transporter: self.transporter, namespace: self.namespace)
    end

    def namespace
      @namespace || ""
    end

    def node_id
      @node_id || "#{Socket.gethostname.downcase}-#{Process.pid}"
    end

    def create_service(klass)
      services << klass
    end

    def services
      @services ||= {}
    end

    def transporter
      @transporter || "redis://localhost"
    end

    def register_service(klass)
      services[klass.moleculer_service_name] = klass
    end

  end
end
