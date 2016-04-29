require 'redis'

module Bazz
  module Utils
    module Redis
      class << self
        attr_accessor :redis
      end
      module ZSet
        def self.top_scores(key, n)
          Redis.redis.zrevrange(key, 0, n-1, :with_scores => true) # => [["b", 64.0], ["a", 32.0]]
        end

        def self.inc_score(key, val)
          Redis.redis.zincrby(key, 1, val)
        end
      end
    end
  end
end