Rails.application.routes.draw do |map|
  # namespace 'trebuchet' do
  scope "trebuchet", :module => "trebuchet_rails" do
    root :to => "features#index"
    get 'timeline' => "features#timeline"
  end
end