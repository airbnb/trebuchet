if Rails::VERSION::STRING =~ /\A2\./ # Rails 2.x

  ActionController::Routing::Routes.draw do |map|
    map.trebuchet '/trebuchet.:format', :controller => 'trebuchet'
  end

else # Rails 3

  Rails.application.routes.draw do
    get "trebuchet" => "trebuchet#index" , :as => :trebuchet
  end

end