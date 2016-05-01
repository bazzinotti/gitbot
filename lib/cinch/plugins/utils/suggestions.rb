require 'cinch'
require_relative 'suggestions_backend'

#foreign accessors
# @dict, @bot, config[:dict]

module Cinch::Plugins::Utils::Suggestions
  # Database backend!!!
  include Redis

  def print_suggestions(m, n)
    response = ""
    nn = truncate_n(m,n)
    ts = top_suggestions(nn)
    response << "┌─ " << "#{class_name} " \
      "Suggestions Leaderboard (Top #{ts.length})" << " ─── " << "\n"
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
    if @bot.admin?(m.user)
      # remove word
      rem_suggestion(word)
      # check if it's already in the dict
      if @dict.word_valid?(word)
        m.reply "\"#{word}\" is already in the dict!"
        return
      end

      # Append it to dictionary
      @dict.words << word
      File.open(@dict.filename, 'a+') do |f|
        f.seek(-1, IO::SEEK_END)
        f << "\n" if f.getc != "\n"
        f << word << "\n"
      end
      m.reply("\"#{word}\" added to dict", true)
    else
      # check if suggestion already exists in dictionary

      # add suggestion
      inc_suggestion(word)
      m.reply('Thank you for your suggestion. My master will review it.', true)
    end
  end

  def self.included(by)
    by.instance_exec do
      self.help << <<-HELP
#{self.const_get :Suggest_str} <word>
  Suggest a word be added to dictionary
HELP
      match(/#{self.const_get :Suggest_str}\s*(\S*)/, method: :suggest)
    end
  end

end
