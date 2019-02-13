require_relative "../../lib/moleculer"

class Server
  include Moleculer::Service
  moleculer_action "echo.string", :echo

  def echo(string)
    string
  end


end

Moleculer.broker.run
