require "benchmark"
require_relative "../../lib/moleculer"
Moleculer.configure do |c|
  c.log_level = :trace
end
Moleculer.start

Moleculer.wait_for_services("math")

result = Moleculer.call("math.add", a: 1, b: 2)

puts result
