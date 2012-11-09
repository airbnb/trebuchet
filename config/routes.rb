Rails.application.routes.draw do |map|
  namespace 'trebuchet' do
    root :to => "features#index"
    get 'timeline' => "trebuchet#timeline"
  end
end