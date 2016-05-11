require 'cinch'

module Cinch::Plugins::Utils
  module Scores
# print the top N scores [nick, score]
    def truncate_n(m, n)
      n = n.to_i
      n = 5 if n == 0 # TODO config[:scores] instead of hardcoded default
      # if n > 10
      #   n = 10
      #   m.reply "I will only print the Top 10 to avoid spam :3\n"
      # end
      n
    end
  end
end