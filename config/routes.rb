# TrebuchetRails::Engine.routes do
Rails.application.routes do
  scope "trebuchet", :module => "trebuchet_rails" do
    root :to => "features#index"
    get 'timeline' => "features#timeline"
  end
end