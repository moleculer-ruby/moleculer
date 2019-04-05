# frozen_string_literal: true

require_relative "../lib/moleculer"

##
# Users is a class for benmarking speed vs Moleculer Node apps
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
