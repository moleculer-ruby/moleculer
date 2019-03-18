require_relative "base"

module Moleculer
  module Packets
    class Info < Base
      include Support

      def initialize(data = {})
        @services = HashUtil.fetch(data, :services)
        @config   = HashUtil.fetch(data, :config)
        @ip_list  = HashUtil.fetch(data, :ip_list)
      end

      private

      def fetch_ip_list(data); end
    end
  end
end
