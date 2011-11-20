Trebuchet
=========

Trebuchet launches features at people. Wisely choose a strategy, aim, and launch!


Setup
-----

Trebuchet can be used with Rails or standalone.

Trebuchet defaults to storing data in memory, or can be used with Redis or Memcache as a data store:
    
    Trebuchet.set_backend :memcached
    Trebuchet.set_backend :redis, :client => Redis.new(:host => 'example.com')


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
        user.has_role?(:admin)
    end

controller.current_user is yielded to the block and it should return true for users you want to launch to.
You can use parameters with custom strategies too:

    Trebuchet.define_strategy(:markets) do |user, markets|
        markets.include?(user.market)
    end

Like parameters for builtin strategies, these can be changed while the application is running. For example:

    Trebuchet.aim('time_machine', :markets, ['San Francisco', 'New York City'])

When using Trebuchet together with Rails, a good place to define custom strategies is in an initializer.
