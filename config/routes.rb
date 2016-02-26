# TrebuchetRails::Engine.routes do

routes_block = lambda do
  scope "trebuchet", :module => "trebuchet_rails" do
    get '/' => "features#index"
    get 'timeline' => "features#timeline"
  end
end

if Rails::VERSION::MAJOR == 3
  case Rails::VERSION::MINOR
  when 0
    Rails.application.routes.draw &routes_block
  when 1
    Rails.application.routes.prepend &routes_block
  when 2
    Rails.application.routes &routes_block
  end
end
