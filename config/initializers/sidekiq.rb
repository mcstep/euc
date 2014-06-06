Sidekiq.configure_server do |config|
  if Rails.env == 'development'
    config.redis = { :url => ENV["REDIS_URL"], :namespace => ENV["REDIS_NAMESPACE"] }
  else
    config.redis = { :url => 'redis://pub-redis-14604.us-east-1-1.1.ec2.garantiadata.com:14604', :namespace => 'portal' }
  end
end

# When in Unicorn, this block needs to go in unicorn's `after_fork` callback:
Sidekiq.configure_client do |config|
  if Rails.env == 'development'
    config.redis = { :url => ENV["REDIS_URL"], :namespace => ENV["REDIS_NAMESPACE"] }
  else
    config.redis = { :url => 'redis://pub-redis-14604.us-east-1-1.1.ec2.garantiadata.com:14604', :namespace => 'portal' }
  end
end

#Sidekiq.configure_server do |config|
#  config.redis = { :url => 'redis://pub-redis-11927.us-east-1-3.3.ec2.garantiadata.com:11927', :namespace => 'portal' }
#end

#Sidekiq.configure_client do |config|
#  config.redis = { :url => 'redis://pub-redis-11927.us-east-1-3.3.ec2.garantiadata.com:11927', :namespace => 'portal' }
#end
