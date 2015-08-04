require 'redis'
require 'redis/objects'

Redis.current = Redis.new(url: ENV['REDIS_URL'])
Redis::Objects.redis = Redis.current