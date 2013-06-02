require 'trebuchet'

# FIXME: happens too early
# def set_trebuchet_namespace(app_name)
#   if Trebuchet.backend.respond_to?(:namespace=)
#     Trebuchet.backend.namespace = "trebuchet-#{app_name}/"
#   end
# end

if defined? Rails
  Trebuchet.use_with_rails!
  
  if Rails.respond_to?(:version) && Rails.version =~ /^3/
    # Rails 3.x
    # no other setup needed  
  else
    # Rails 2.x
    load_paths.each do |path|
       ActiveSupport::Dependencies.load_once_paths.delete(path)
    end if config.environment == 'development'
    # set_trebuchet_namespace "#{Rails.root.basename}-#{Rails.env}" 
  end
end