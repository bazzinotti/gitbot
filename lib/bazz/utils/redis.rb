require 'redis'

module Bazz
  module Utils
    module Redis
      class << self
        attr_accessor :redis
      end

      def self.get(key)
        Redis.redis.get(key)
      end

      def self.set(key, val, options={})
        Redis.redis.set(key, val, options)
      end


      module ZSet
        def self.top_scores(key, n)
          Redis.redis.zrevrange(key, 0, n-1, :with_scores => true) # => [["b", 64.0], ["a", 32.0]]
        end

        def self.inc_score(key, val)
          Redis.redis.zincrby(key, 1, val)
        end

        def self.rem_score(key, val)
          Redis.redis.zrem(key, val)
        end
      end
    end
  end
end