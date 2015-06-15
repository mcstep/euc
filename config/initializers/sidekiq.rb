Sidekiq.configure_server do |config|
  if Rails.env == 'development'
    config.redis = { :url => ENV["REDIS_URL"], :namespace => ENV["REDIS_NAMESPACE"] }
  end
end

# When in Unicorn, this block needs to go in unicorn's `after_fork` callback:
Sidekiq.configure_client do |config|
  if Rails.env == 'development'
    config.redis = { :url => ENV["REDIS_URL"], :namespace => ENV["REDIS_NAMESPACE"] }
  end
end