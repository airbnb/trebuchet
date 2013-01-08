module TrebuchetHelper

  def feature(feature)
    "<dd>#{feature.name}</dd>
    <dt><ul>#{strategy feature.strategy}</ul></dt>"
  end
  
  def strategy(strategy)
    html =  case strategy.name
            when :multiple
              strategy.strategies.map { |s| strategy s }.join().html_safe
            else
              strategy.to_s
            end
    strategy.name == :multiple ? html : content_tag(:li, html)
  end
  
  def trebuchet_css
    filename = File.expand_path(File.dirname(__FILE__) + "/../views/trebuchet_rails/trebuchet.css")
    return IO.read(filename)
  end
  
end