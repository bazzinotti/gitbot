require 'cinch'
require_relative 'suggestions_backend'

#foreign accessors
# @dict, @bot, config[:dict]

module Cinch::Plugins::Utils::Suggestions
  Driver = Redis
  attr_reader :suggestions

  def initialize(*args)
    super
    @suggestions = Driver.new(self)
  end

  def suggest(m, words)
    return self.suggestions.print_suggestions(m, 5) if words.empty?
    return self.suggestions.print_suggestions(m, words.to_i) if words =~ /\d/

    words.split.each do |word|
      if @bot.admin?(m.user)
        # remove word
        self.suggestions.rem_suggestion(word)
        # check if it's already in the dict
        next m.reply "\"#{word}\" is already in the dict!" if @dict.word_valid?(word)

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
        self.suggestions.inc_suggestion(word)
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
