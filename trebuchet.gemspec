# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "trebuchet/version"

Gem::Specification.new do |s|
  s.name        = "trebuchet"
  s.version     = Trebuchet::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tobi Knaup"]
  s.email       = ["tobi.knaup@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Trebuchet launches features at people}
  s.description = %q{Trebuchet launches features at people}

  s.rubyforge_project = "trebuchet"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency("rspec", ["~> 2.5.0"])
    else
    end
  else
  end
end
