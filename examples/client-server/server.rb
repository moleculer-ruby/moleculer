require_relative "../../lib/moleculer"

broker = Moleculer::Broker.new(
  node_id: "client-server",
)


broker.start()
