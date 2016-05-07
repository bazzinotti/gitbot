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

  def suggest(m, words)
    return print_suggestions(m, 5) if words.empty?

    words.split.each do |word|
      if @bot.admin?(m.user)
        # remove word
        rem_suggestion(word)
        # check if it's already in the dict
        return m.reply "\"#{word}\" is already in the dict!" if @dict.word_valid?(word)

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
        return m.reply "\"#{word}\" is already in the dict!" if @dict.word_valid?(word)
        # add suggestion
        inc_suggestion(word)
        m.reply('Thank you for your suggestion. My master will review it.', true)
      end
    end
  end

  def self.included(by)
    by.instance_exec do
      self.help << <<-HELP
#{self.const_get :Suggest_str} <word>
  Suggest a word be added to dictionary
HELP
      match(/#{self.const_get :Suggest_str}\s*(.*)/, method: :suggest)
    end
  end

end
