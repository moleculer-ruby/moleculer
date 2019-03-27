require_relative "../../lib/moleculer"

class Server < Moleculer::Service::Base
  service_name "ruby-server"
  action "echo", :echo
  # moleculer_event "reply.event", :handle_event

  def echo(context)
    {message: "You said #{context.params["message"]}"}
  end

  def self.handle_event(request)
    puts "\n\n\n\n\n\n\n#{request.data["counter"]}"
  end

end

Moleculer.config do |c|
  c.services << Server
end

Moleculer.run


