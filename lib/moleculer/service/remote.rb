module Moleculer
  ##
  # @private
  module Service
    ##
    # Creates a service instance from remote service info
    #
    # @param [Hash] service_info remote service information
    def self.from_remote_info(service_info, service_node)
      Class.new(Remote) do
        service_name Support::HashUtil.fetch(service_info, :name)
        fetch_actions(service_info)
        node service_node
      end
    end

    ##
    # Represents a remote service
    class Remote < Base
      class << self
        def node(n = nil)
          @node = n if n
          @node
        end

        private

        def action_name_for(name)
          name
        end

        def fetch_actions(service_info)
          seq = 0
          Support::HashUtil.fetch(service_info, :actions).values.each do |a|
            next if Support::HashUtil.fetch(a, :name) =~ /^\$/

            define_method("action_#{seq}".to_sym) do |ctx|
              Moleculer.broker.publish_req(
                id:         ctx.id,
                action:     ctx.action.name,
                params:     ctx.params,
                meta:       ctx.meta,
                timeout:    ctx.timeout,
                node:       self.class.node,
                request_id: ctx.request_id,
                stream:     false,
              )
              {}
            end
            action(Support::HashUtil.fetch(a, :name), "action_#{seq}".to_sym)
            seq += 1
          end
        end
      end
    end
  end
end
