require 'cinch'
require_relative 'suggestions_backend'

module Cinch::Plugins::Utils::Suggestions
  # Database backend!!!
  include Redis

  def print_suggestions(m, n)
    response = ""
    nn = truncate_n(m,n)
    ts = top_suggestions(nn)
    response << "┌─ " << "Leaderboard (Top #{ts.length})" << " ─── " << "\n"
    ts.each_with_index do |us, ix|
      num_wins = us[1].to_i
      response << "RANK #{ix+1}) #{us[0]} - #{num_wins} times\n"
    end
    response << "\n" << "└ ─ ─ ─ ─ ─ ─ ─ ─\n"
    m.reply(response)
  end

  def suggest(m, word)
    return print_suggestions(m, 5) if word.empty?
    #word = word.downcase
    #set = "#{self.class.plugin_name}:dict_suggestions"
    #if @bot.redis.sismember(set, word)
    #  return m.reply 'That word has already been suggested, but thanks!'
    #end
    #@bot.redis.sadd(set, word)

    #@bot.redis.zincrby(set, 1, word)
    inc_suggestion(word)
    m.reply('Thank you for your suggestion', true)
  end

  def self.included(by)
    by.instance_exec do
      match(/#{self.const_get :Suggest_str}\s*(\S*)/, method: :suggest)
    end
  end

end
