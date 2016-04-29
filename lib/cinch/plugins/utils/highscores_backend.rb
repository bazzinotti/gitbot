require 'redis'

module Cinch::Plugins
  module Utils
    module Highscores
      module BackendInterface
        def table
          raise NotImplementedError, "Implement this method in a child class"
        end
        
        def top_scores(n)
          raise NotImplementedError, "Implement this method in a child class"
        end

        # increments a user's score by 1
        def inc_score(user)
          raise NotImplementedError, "Implement this method in a child class"
        end

        # print the top N scores [nick, score]
        def print_top_scores(m, n)
          response = ""
          n = n.to_i
          n = 5 if n == 0
          if n > 10
            n = 10
            response << "I will only print the Top 10 to avoid spam :3\n"
          end

          ts = top_scores(n)
          response << "┌─ " << "Leaderboard (Top #{ts.length})" << " ─── " << "\n"
          ts.each_with_index do |us, ix|
            num_wins = us[1].to_i
            response << "RANK #{ix+1}) #{us[0]} - #{num_wins} win#{"s" if num_wins > 1}\n"
          end
          
          response << "\n" << "└ ─ ─ ─ ─ ─ ─ ─ ─\n"
          
          m.reply(response)
        end
      end

      module BackendRedis
        include BackendInterface
        include Bazz::Utils::Redis

        def table
          "#{self.class.plugin_name}:highscores"
        end

        # increments a user's score by 1
        def inc_score(user)
          ZSet.inc_score(table, user)
        end

        def top_scores(n)
          ZSet.top_scores(table, n)
        end
      end
    end
  end
end
