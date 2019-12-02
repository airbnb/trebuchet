source "http://rubygems.org"

# Specify your gem's dependencies in trebuchet.gemspec
gemspec

current_ruby = Gem::Version.new(RUBY_VERSION)
if current_ruby < Gem::Version.new("2.2")
  gem "rake", "< 12.3"
end
