module TrebuchetHelper

  def feature(feature)
    "<dd>#{feature.name}</dd>
    <dt><ul>#{strategy feature.strategy}</ul></dt>"
  end
  
  def strategy(strategy)
    html = case strategy.name
    when nil
      default_strategy(strategy)
    else
      method = :"#{strategy.name}_strategy"
      if respond_to?(method)
        send(method, strategy)
      else
        unsupported_strategy(strategy)
      end
    end
    html = if (strategy.name == :multiple)
      html.join('').html_safe # used recursively, so don't wrap outer with <li>
    else
      content_tag(:li, html)
    end
  end
  
  def users_strategy(strategy)
    user_ids = strategy.user_ids.to_a
    str = "user ids: "
    str << (user_ids.empty? ? 'none' : "#{user_ids.join(', ')}")
    str
  end
  
  def percent_strategy(strategy)
    percent = strategy.percentage
    offset = strategy.offset
    low_id = (0 + offset).to_s.rjust(2, '0')
    high_id = ((percent + offset - 1) % 100).to_s.rjust(2, '0')
    str = "#{percent}%"
    if percent == 0 
      str << " (no users)"
    elsif percent == 100
      str << " (all users)"
    elsif high_id.to_i < low_id.to_i # wrapped past 100 due to offset
      str << " (user id ending with #{low_id} to 99 "
      str << " and 00"
      str << " to #{high_id}" if high_id != '00'
      str << ")"
    else
      str << " (user id ending with #{low_id}" 
      str << " to #{high_id}" if high_id != low_id
      str << ")"
    end
    str
  end

  def experiment_strategy(strategy)
    str = "bucket (#{strategy.bucket.join(', ')}) for experiment: #{strategy.experiment_name}"
    
    str
  end
  
  def multiple_strategy(strategy)
    strategy.strategies.map do |s|
      strategy s
    end
  end
  
  def default_strategy(strategy)
    "feature not launched"
  end
  
  def custom_strategy(strategy)
    "#{strategy.custom_name} (custom) #{strategy.options.inspect if strategy.options}"
  end
  
  def invalid_strategy(strategy)
    "#{strategy.invalid_name} (invalid) #{strategy.options.inspect if strategy.options}"
  end
  
  def unsupported_strategy(strategy)
    "#{strategy.name} (unsupported)"
  end
  
  def trebuchet_css
    filename = File.expand_path(File.dirname(__FILE__) + "/../views/trebuchet/trebuchet.css")
    return IO.read(filename)
  end
  
end