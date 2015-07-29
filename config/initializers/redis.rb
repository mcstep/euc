require 'redis'
require 'redis/objects'

config = YAML.load(File.open(Rails.root.join 'config/redis.yml')).symbolize_keys

Redis.current = Redis.new(config[Rails.env.to_sym])
Redis::Objects.redis = Redis.current