require 'rails'

module TrebuchetRails
  class Engine < Rails::Engine
    isolate_namespace TrebuchetRails
  end
end


Trebuchet.use_with_rails!