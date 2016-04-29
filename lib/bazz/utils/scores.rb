require_relative 'redis'

module Bazz
  module Utils
    module Scores
      module Interface
        def top_scores(table, n)
          raise NotImplementedError, "Implement this method in a child class"
        end

        # increments a user's score by 1
        def inc_score(table, user)
          raise NotImplementedError, "Implement this method in a child class"
        end
      end

      module Redis
        include Interface
        include Bazz::Utils::Redis
        def top_scores(table, n)
          ZSet.top_scores(table, n)
        end

        # increments a user's score by 1
        def inc_score(table, user)
          ZSet.inc_score(table, user)
        end
      end

    end
  end
end