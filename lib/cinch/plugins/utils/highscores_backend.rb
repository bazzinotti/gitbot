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

        def highscore_time(user)
          "#{highscore_table}:#{user}:time"
        end

        # increments a user's score by 1
        def inc_highscore(user)
          inc_score(highscore_table, user)
          # update time
          set(highscore_time(user), Time.new.to_i.to_s)
        end

        def rem_highscore(user)
          rem_score(highscore_table, user)
        end

        def top_highscores(n)
          scores = top_scores(highscore_table, n)
          real_scores = []
          last_user, last_score = scores[0]
          users = [last_user]
          scores.each do |user, score|
            # check if this score is already present
            if last_score != score
              # check if there are scores to sort!!
              if users.size > 1
                # let's do fun sorting!!
                user_time = []
                users.each do |u|
                  user_time << [u, highscore_time(u).to_i]
                end
                # sort it
                user_time.sort_by(&:last).each do |u, t|
                  real_scores << [u, last_score]
                end
                users.clear
              else
                # if not, just add it to real_scores
                real_scores << [users[0], last_score]
              end
            end
            users << user
            last_score = score
          end
        end
      end
    end
  end
end
