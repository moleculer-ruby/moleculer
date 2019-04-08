require "uri"

module Moleculer
  ##
  # Transporters allow you to run services on multiple nodes. They provide the communication channels for other with
  # other nodes handling the transfer of events, action calls and responses, ...etc.
  module Transporters

    ##
    # Returns a new transporter for the provided transporter uri
    #
    # @param [String] uri the transporter uri
    # @param [Moleculer::Broker] broker the broker instance
    #
    # @return [Moleculer::Transporters::Base] the transporter instance
    def self.for(uri)
      parsed = URI(uri)
      require_relative("./transporters/#{parsed.scheme}")
      const_get(parsed.scheme.split("_").map(&:capitalize).join).new
    end
  end
end
