require_relative "../../lib/moleculer"
Moleculer.start
  .wait_for_service("math")


# async call
Moleculer.call("math.add", {count: 1, a: 3, b: 3}) do |_, response|
  puts "The async answer is #{response.data["res"]}"
end

timeout = 0

until timeout == 5
  puts "sleeping for 5 seconds"
  sleep 1
  timeout += 1
end

# sync call
puts "The sync answer is #{Moleculer.call("math.add", {count: 1, a: 2, b: 3}).data["res"]}"
