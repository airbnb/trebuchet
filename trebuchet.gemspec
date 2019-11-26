# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'trebuchet'

Gem::Specification.new do |s|
  s.name        = "trebuchet"
  s.version     = Trebuchet::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Justin Jones", "Tobi Knaup", "Ross Allen"]
  s.email       = ["justin@airbnb.com"]
  s.homepage    = "http://www.airbnb.com"
  s.summary     = %q{Trebuchet launches features at people}
  s.description = %q{Wisely choose a strategy, aim, and launch!}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # redis and memcache are optional
  s.add_dependency 'json'

  s.add_development_dependency 'rspec', '~> 2.12.0'
  s.add_development_dependency 'mock_redis', '~> 0.6.5'
  s.add_development_dependency 'rake', '>= 10.0.3'
end
