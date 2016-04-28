module Cinch
  module Plugin
    module Highscores
      def self.included(by)
        by.instance_exec do
          puts "#{self.const_get :Highscores_str}\n\n"
          match(/#{self.const_get :Highscores_str}\s*([0-9]*)/, method: :print_top)
        end
      end

      def highscores
        "highscores_#{self.class.plugin_name}"
      end

      # get the top n scores
      def get_top(n)
        @bot.redis.zrevrange(highscores, 0, n-1, :with_scores => true) # => [["b", 64.0], ["a", 32.0]]
      end

      # increments a user's score by 1
      def inc_score(user)
        @bot.redis.zincrby(highscores, 1, user)
      end

      # print the top N scores
      def print_top(m, n)
        response = ""
        n = n.to_i
        n = 5 if n == 0
        if n > 10
          n = 10
          response << "I will only print the Top 10 to avoid spam :3\n"
        end

        top_scores = get_top(n)
        n = top_scores.length if top_scores.length < n

        response << "┌─ " << "Leaderboard (Top #{n})" << " ─── " << "\n"
        top_scores.each_with_index do |us, ix|
          num_wins = us[1].to_i
          response << "RANK #{ix+1}) #{us[0]} - #{num_wins} win#{"s" if num_wins > 1}\n"
        end
        
        response << "\n" << "└ ─ ─ ─ ─ ─ ─ ─ ─\n"
        
        m.reply(response)
      end

    end
  end
end
