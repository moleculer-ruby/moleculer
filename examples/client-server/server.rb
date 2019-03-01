require_relative "../../lib/moleculer"

class Server
  include Moleculer::Service
  moleculer_service_name "ruby-server"
  moleculer_action "echo", :echo
  moleculer_event "reply.event", :handle_event

  def self.echo(request)
    {message: "You said #{request.params["message"]}"}
  end

  def self.handle_event(request)
    puts "\n\n\n\n\n\n\n#{request.data["counter"]}"
  end

end

Moleculer.broker.run


