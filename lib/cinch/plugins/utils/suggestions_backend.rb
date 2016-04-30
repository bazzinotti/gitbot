require 'redis'

module Cinch::Plugins
  module Utils
    module Suggestions
      include Cinch::Plugins::Utils::Scores

      module BackendInterface
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

      module Redis
        include BackendInterface
        include Bazz::Utils::Scores::Redis

        def suggestions_table
          "#{self.class.plugin_name}:suggestions"
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
