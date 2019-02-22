require_relative "../../lib/moleculer"

class Server
  include Moleculer::Service
  moleculer_service_name "ruby-server"
  moleculer_action "echo", :echo

  def self.echo(params)
    puts "\n\n\n\n\n\n\n" + params["message"]
  end

end

Moleculer.broker.run
