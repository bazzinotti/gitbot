require 'redis'

module Cinch::Plugins
  module Utils
    module HighScores
      include Cinch::Plugins::Utils::Scores

      module BackendInterface
        def highscore_table
          raise NotImplementedError, "Implement this method in a child class"
        end

        def inc_highscore
          raise NotImplementedError, "Implement this method in a child class"
        end

        def rem_highscore
          raise NotImplementedError, "Implement this method in a child class"
        end

        def top_highscores
          raise NotImplementedError, "Implement this method in a child class"
        end
      end

      module Redis
        include BackendInterface
        include Bazz::Utils::Scores::Redis

        def highscore_table
          "#{self.class.plugin_name}:highscores"
        end

        # increments a user's score by 1
        def inc_highscore(user)
          inc_score(highscore_table, user)
        end

        def rem_highscore(user)
          rem_score(highscore_table, user)
        end

        def top_highscores(n)
          top_scores(highscore_table, n)
        end
      end
    end
  end
end
