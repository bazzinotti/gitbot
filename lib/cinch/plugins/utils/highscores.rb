require 'cinch'
require_relative 'scores'
require_relative 'highscores_backend'

module Cinch::Plugins::Utils::HighScores
  # Database backend!!!
  include Redis

  def print_highscores(m, n)
    response = ""
    nn = truncate_n(m,n)
    ts = top_highscores(nn)
    response << "┌─ " << "Leaderboard (Top #{ts.length})" << " ─── " << "\n"
    ts.each_with_index do |us, ix|
      num_wins = us[1].to_i
      response << "RANK #{ix+1}) #{us[0]} - #{num_wins} win#{"s" if num_wins > 1}\n"
    end
    response << "\n" << "└ ─ ─ ─ ─ ─ ─ ─ ─\n"
    m.reply(response)
  end

  def self.included(by)
    by.instance_exec do
      match(/#{self.const_get :Highscores_str}\s*([0-9]*)/, method: :print_highscores)
    end
  end
end
