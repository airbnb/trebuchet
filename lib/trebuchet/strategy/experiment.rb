require 'digest/sha1'

class Trebuchet::Strategy::Experiment < Trebuchet::Strategy::Base

  attr_reader :bucket, :total_buckets, :experiment_name

  def initialize(options = {})
    options.keys.each {|k| options[k.to_sym] = options.delete(k)} # cheap symbolize_keys
    @experiment_name = options[:name]
    @bucket = [ options[:bucket] ].flatten # always treat as an array
    @total_buckets = options[:total_buckets] || 5
  end

  def launch_at?(user, request = nil)
    return false unless self.valid?
    # must hash feature name and user id together to ensure uniform distribution
    b = Digest::SHA1.hexdigest("experiment: #{@experiment_name.downcase} user: #{user.id}").to_i(16) % total_buckets
    !!@bucket.include?(b + 1) # is user in this bucket?
  end
  
  def valid?
    experiment_name && total_buckets > 0 && bucket.max <= total_buckets && (1..total_buckets).include?(bucket.min)
  rescue
    false
  end
  
  def as_json
    {:name => experiment_name, :bucket => bucket, :total_buckets => total_buckets}
  end

end