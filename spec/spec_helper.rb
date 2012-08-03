$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'bundler'

# Bundler breaks things
#Bundler.require :default, :development

require 'trebuchet'
require 'user'

# uncomment to run specs against Redis backend instead of Memory backend
# Trebuchet.backend = :redis

def should_launch(feature, users)
  should_or_should_not_launch(feature, users, be_true)
end

def should_not_launch(feature, users)
  should_or_should_not_launch(feature, users, be_false)
end

def should_or_should_not_launch(feature, users, be_true_or_false)
  Array(users).each do |user_or_user_id|
    user = user_or_user_id.is_a?(User) ? user_or_user_id : User.new(user_or_user_id)
    Trebuchet.new(user).launch?(feature).should be_true_or_false
  end
end

def mock_request(cookie = nil)
  mock 'Request', :cookies => {:visitor => cookie}
end