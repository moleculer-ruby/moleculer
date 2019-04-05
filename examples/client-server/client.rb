require "benchmark"
require_relative "../../lib/moleculer"
Moleculer.start

Moleculer.wait_for_services("math")

Moleculer.emit("echo.event", counter: 1)

result = Moleculer.call("math.add", a: 1, b: 2)

puts result
