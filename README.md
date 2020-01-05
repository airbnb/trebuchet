Trebuchet
=========

Trebuchet launches features at people. Wisely choose a strategy, aim, and launch!

Installation
------------


Trebuchet can be used with Rails or standalone.

To use with Rails:
gem 'trebuchet', :require => 'trebuchet_rails'

Setup
-----


Trebuchet defaults to storing data in memory, or can be used with Redis or Memcache as a data store:

    Trebuchet.set_backend :memcached
    Trebuchet.set_backend :redis, :client => Redis.new(:host => 'example.com')
    Trebuchet.set_backend :redis_cached, :client => Redis.new(:host => 'example.com')

A Rails initializer is a great spot for this. You may want to use a few other settings, either hardcoded values or procs (eval'd in the context of the controller):

    Trebuchet.admin_view = proc { current_user.try(:admin?) } # /trebuchet admin interface access
    Trebuchet.time_zone = proc { current_user.time_zone } # or just "Mountain Time (US & Canada)"


Aim
---

Trebuchet can be aimed while your application is running. The syntax is:

    Trebuchet.aim('awesome_feature', :percent, 1)

Which will launch 'awesome_feature' to 1% of users.

Another builtin strategy allows launching to particular user IDs:

    Trebuchet.aim('awesome_feature', :users, [23, 42])

You can also combine multiple strategies, in which case the feature is launched if any of them is true:

    Trebuchet.feature('awesome_feature').aim(:percent, 1).aim(:users, [23, 42])

If you don't aim Trebuchet for a feature, the default action is not to launch it to anyone.


Launch
------

In a view, do this:

    <% trebuchet.launch('time_machine') do %>
        <p>Welcome to the future!</p>
    <% end %>

The code between do .. end will only run if the strategy for 'time_machine' allows launching to current_user.

You can also use it in a controller:

    def index
      trebuchet.launch('time_machine') do
        @time_machine = TimeMachine.new
      end
    end


Custom Strategies
-----------------

Trebuchet ships with a number of default strategies but you can also define your own custom strategies like so:

    Trebuchet.define_strategy(:admins) do |user|
      !!(user && user.has_role?(:admin))
    end

controller.current_user is yielded to the block and it should return true for users you want to launch to.
You can use parameters with custom strategies too:

    Trebuchet.define_strategy(:markets) do |user, markets|
        markets.include?(user.market)
    end

Like parameters for builtin strategies, these can be changed while the application is running. For example:

    Trebuchet.aim('time_machine', :markets, ['San Francisco', 'New York City'])

When using Trebuchet together with Rails, a good place to define custom strategies is in an initializer.


Visitor Strategy
----------------

Trebuchet can be used to launch to visitors (no user object present).
First, set the visitor id either directly (in a before filter) or as a proc:

    Trebuchet.visitor_id = 123

    Trebuchet.visitor_id = proc { |request| request && request.cookies[:visitor] && request.cookies[:visitor].hash }

If you're using a proc, Trebuchet passes in the request object. It expects that the proc returns an integer.
If it returns anything else, Trebuchet will not launch.

Fiber and Thread Safety
-------------

Trebuchet stores global state such as `Trebuchet.current` which is thread and fiber unsafe behavior. In order to use these
features in a fiber or threaded environment, `Trebuchet.threadsafe_state = true` will cause Trebuchet to store these values
in a thread-local state object instead. This is not the default for backward compatability reasons.
