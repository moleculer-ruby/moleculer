require_relative "../../lib/moleculer"

class Server < Moleculer::Service::Base
  service_name "ruby-server"
  action "echo", :echo
  event "reply.event", :handle_event

  def echo(context)
    {message: "You said #{context.params["message"]}"}
  end

  def handle_event(data, options={})
    puts "\n\n\n\n\n\n\n#{data["counter"]}"
  end

end

Moleculer.config do |c|
  c.services << Server
end

Moleculer.run


