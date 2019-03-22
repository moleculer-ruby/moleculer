module Moleculer
  ##
  # @private
  module Service
    ##
    # Creates a service instance from remote service info
    #
    # @param [Hash] service_info remote service information
    def self.from_remote_info(service_info)
      Class.new(Remote) do
        service_name Support::HashUtil.fetch(service_info, :name)
        fetch_actions(service_info)
      end
    end

    ##
    # Represents a remote service
    class Remote < Base
      class << self

        private
        def fetch_actions(service_info)
          seq = 0
          Support::HashUtil.fetch(service_info, :actions).values.each do |a|
            next if Support::HashUtil.fetch(a, :name) =~ /^\$/
            define_method("action_#{seq}".to_sym) do |ctx|
              Moleculer.broker.publish_req(ctx)
            end
            action(Support::HashUtil.fetch(a, :name), "action_#{seq}".to_sym)
            seq += 1
          end
        end
      end
    end
  end
end
