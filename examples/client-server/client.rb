require_relative "../../lib/moleculer"
Moleculer.start

Moleculer.wait_for_services("ruby-server")

# result = Moleculer.call("math.add", {a: 1, b: 2})
#
# puts result


result = Moleculer.call("ruby-server.echo", {message: "echo"})

puts result
