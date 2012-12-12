require 'rails'

module TrebuchetRails
  class Engine < Rails::Engine
    # isolate_namespace Trebuchet
  end
end


Trebuchet.use_with_rails!