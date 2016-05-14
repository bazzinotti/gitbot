require 'redis'

module Cinch::Plugins
  module Utils
    module Suggestions
      module BackendInterface
        include Cinch::Plugins::Utils::Scores
        def print_suggestions(m, n)
          response = ""
          nn = truncate_n(m,n)
          ts = top_suggestions(nn)
          response << "┌─ " << "#{@owner.class_name} " \
            "Suggestions Leaderboard" << " ─── " << "(Top #{ts.length})" << " ─" << "\n"
          ts.each_with_index do |us, ix|
            num_wins = us[1].to_i
            response << "RANK #{ix+1}) #{us[0]} - #{num_wins} time#{"s" if num_wins > 1}\n"
          end
          response << "\n" << "└ ─ ─ ─ ─ ─ ─ ─ ─\n"
          m.reply(response)
        end

        def suggestions_table
          raise NotImplementedError, "Implement this method in a child class"
        end

        def inc_suggestion
          raise NotImplementedError, "Implement this method in a child class"
        end

        def top_suggestions
          raise NotImplementedError, "Implement this method in a child class"
        end

        def rem_suggestion
          raise NotImplementedError, "Implement this method in a child class"
        end
      end

      class Redis
        include BackendInterface
        include Bazz::Utils::Scores::Redis

        def initialize(owner)
          @owner = owner
        end

        def suggestions_table
          "#{@owner.class.plugin_name}:suggestions"
        end

        # increments a user's score by 1
        def inc_suggestion(word)
          inc_score(suggestions_table, word)
        end

        def rem_suggestion(word)
          rem_score(suggestions_table, word)
        end

        def top_suggestions(n)
          top_scores(suggestions_table, n)
        end
      end
    end
  end
end
