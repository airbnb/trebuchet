require 'rails'
require File.expand_path(File.dirname(__FILE__) + "/../trebuchet")


module TrebuchetRails
  class Engine < Rails::Engine
    isolate_namespace TrebuchetRails if respond_to?(:isolate_namespace)
  end
end


Trebuchet.use_with_rails!