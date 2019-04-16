require_relative "../../lib/moleculer"

class Server < Moleculer::Service::Base
  service_name "math"
  action "add", :add
  event "echo.event", :echo

  def add(ctx)
    {
      count: ctx.params.count,
      res:   ctx.params["a"].to_i + ctx.params["b"].to_i,
    }
  end

  def echo(data)
    broker.emit("reply.event", data)
  end
end

Moleculer.configure do |c|
  c.log_level = :trace
  c.services << Server
end

Moleculer.run
