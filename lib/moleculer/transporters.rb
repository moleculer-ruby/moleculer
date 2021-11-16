
module Moleculer
  ##
  # Transporter communicates with other nodes. It transfers events, calls requests
  # and processes responses …etc. If multiple instances of a service are running on
  # different nodes then the requests will be load-balanced among them. The whole
  # communication logic is outside of transporter class. It means that you can
  # switch between transporters without changing any line of code.
  module Transporters
    def self.get(name)
      case name
      when "fake"
        Transporters::Fake
      else
        raise ArgumentError, "Transporter #{name} not found"
      end
    end
  end
end
