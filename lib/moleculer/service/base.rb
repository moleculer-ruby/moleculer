# frozen_string_literal: true

require_relative "actions"
require_relative "events"
require_relative "settings"
require_relative "metadata"
require_relative "schema"
require_relative "lifecycle"
require_relative "naming"

module Moleculer
  module Service
    ##
    # The Service represents a microservice in the Moleculer framework. You
    # can define actions and subscribe to events. To create a service you must
    # define a schema.
    #
    # # Settings
    # The settings property is a static store, where you can store every
    # settings/options to your service. The settings is also obtainable on
    # remote nodes. It is transferred during service discovering.
    #
    # ## Internal Settings
    # There are some internal settings which are used by core modules. These
    # setting names start with $ (dollar sign).
    #
    # | Name | Type | Default | Description |
    # |------|------|---------|-------------|
    # | $no_version_prefix | Boolean | false |
    # Disable version prefixing in action names. |
    # | $no_service_name_prefix | Boolean | false |
    # Disable service name prefixing in action names |
    # | $dependency_timeout | Number | 0 | Timeout for dependency waiting. |
    # | $dependency_timeout |  Number | 0 | Timeout for dependency waiting. |
    # | $secure_settings | Array | [] | List of secure settings. |
    #
    # ## Secure Service Settings
    #
    # To protect your tokens & API keys, define a `$secure_settings: []`
    # property in service settings and set the protected property keys. The
    # protected settings wont be published to other nodes and it wont appear
    # in Service Registry.
    #
    # ```ruby
    # class Mailer < Moleculer::Service::Base
    #   service_name "mailer"
    #
    #   settings(
    #     "$secure_settings": ["transport.auth.user", "transport.auth.pass"],
    #     transport: {
    #       service: 'gmail',
    #       auth: {
    #         user: "gmail.user@gmail.com",
    #         pass: "yourpass"
    #       }
    #     }
    #   )
    # end
    # ```
    #
    # # Actions
    #
    # The actions are the callable/public methods of the service. They are
    # callable with broker.call or ctx.call.
    #
    # There are three ways an action can be defined, the first is simply by
    # calling `action <name>`. The endpoint
    # for the action will be whatever value was set for `<name>` and calling
    # that action will call the method of
    # the same name on the service.
    #
    # The second way a method can be explicitly given. In this case the action
    # name and the method may be
    # different.
    #
    # The third and final way is to provide a block to the action method. This
    # block will act as the handler for that service endpoint.
    #
    # ```ruby
    # class Math < Moeculer::Service::Base
    #   service_name "math"
    #
    #   action :add
    #   action :mult, cache: false, method: :multiply
    #
    #   action :div do |ctx|
    #     ctx.params.a / ctx.params.b
    #   end
    #
    #   def add(ctx)
    #     ctx.params.a + ctx.params.b
    #   end
    #
    #   def multiply(ctx)
    #     # The action properties are accessible as `ctx.action.*`
    #     if ctx.action.cache
    #       ctx.params.a * ctx.params.b
    #     end
    #   end
    # end
    # ```
    #
    # You can call the actions as
    #
    # ```ruby
    #    response = broker.call("math.add", {a: 5, b: 7})
    #    response = broker.call("math.mult", {a: 10, b: 31})
    #    response = broker.call("math.div", {a: 12, b: 6})
    # ```
    #
    # Inside actions, you can call other nested actions in other services with
    # `ctx.call` method. It is an alias to `broker.call`, but it sets itself as
    # parent context (due to correct tracing chains).
    #
    # ```ruby
    # class Posts < Moleculer::Service::Base
    #   service_name "posts"
    #
    #   action :get
    #
    #   def get(ctx)
    #     post = posts[ctx.params.id]
    #
    #     user = ctx.call("users.get", {id: post.author})
    #
    #     if user
    #       post.author = user
    #     end
    #   end
    # end
    # ```
    #
    # # Events
    # You can subscribe to events by using the `event` class method.
    #
    # ```ruby
    # class Report < Moleculer::Service::Base
    #   service_name "report"
    #
    #   event "user.created", :user_created
    #   event "user*", :user_event
    #
    #   def user_created(ctx)
    #     #...
    #   end
    #
    #   def user_event(ctx)
    #     #...
    #   end
    # end
    # ```
    #
    # ## Grouping
    # The broker groups the event listeners by group name. By default, the
    # group name is the service name. But you can overwrite it in the event
    # definition.
    #
    # ```ruby
    # class Payment < Moleculer::Service::Base
    #   service_name "payment"
    #
    #   event "order.created", method: :process_payment, group: "other"
    # end
    # ```
    class Base
      include Logging
      include Settings
      include Metadata
      include Actions
      include Events
      include Naming
      include Schema
      include Lifecycle

      attr_reader :broker

      def initialize(broker)
        super
        @broker = broker
      end
    end
  end
end
