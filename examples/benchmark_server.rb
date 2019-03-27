require_relative "../lib/moleculer"

class Users < Moleculer::Service::Base
  service_name "users"
  action "empty", :empty

  def empty(_context)
    {}
  end
end


Moleculer.config do |c|
  c.services << Users
  c.log_level = :info
end

Moleculer.run
