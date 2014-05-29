Sidekiq.configure_server do |config|
  config.redis = { :url => 'redis://pub-redis-11927.us-east-1-3.3.ec2.garantiadata.com:11927', :namespace => 'portal' }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => 'redis://pub-redis-11927.us-east-1-3.3.ec2.garantiadata.com:11927', :namespace => 'portal' }
end
