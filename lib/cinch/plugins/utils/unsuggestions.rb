require 'cinch'
require_relative 'unsuggestions_backend'

#foreign accessors
# @dict, @bot, config[:dict]

module Cinch::Plugins::Utils::Unsuggestions
  Driver = Redis
  attr_reader :unsuggestions

  def initialize(*args)
    super
    @unsuggestions = Driver.new(self)
  end

  def unsuggest(m, words)
    return self.unsuggestions.print_suggestions(m, 5) if words.empty?
    return self.unsuggestions.print_suggestions(m, words.to_i) if words =~ /\d/

    words.split.each do |word|
      word = word.downcase
      if @bot.admin?(m.user)
        # remove word from database
        self.unsuggestions.rem_suggestion(word)
        # check if it's already in the dict
        next m.reply "\"#{word}\" is not in the dict!" if !@dict.word_valid?(word)

        # Remove it from the dictionary (in memory, and file)
        @dict.words.delete(word)
        File.open(@dict.filename, 'r+') do |f|
          f.any? do |line|
            if line[0..-2] == word	# removes '\n' for comparison
            	#puts line.bytes.map { |b| sprintf("0x%02X ", b) }.join
              f.seek(-line.length, IO::SEEK_CUR)

              # overwrite line with spaces and add a newline char
              f.write(' ' * (line.length - 1))
              f.write("\n")
              m.reply("\"#{line[0..-2]}\" removed from dict", true)
              break
            end
          end
        end
        
      else
        # check if suggestion already exists in dictionary
        return m.reply "\"#{word}\" is not in the dict!" if !@dict.word_valid?(word)
        # add suggestion
        self.unsuggestions.inc_suggestion(word)
        m.reply('Thank you for your unsuggestion. My master will review it.', true)
      end
    end
  end

  def self.included(by)
    by.instance_exec do
      self.help << <<-HELP
#{self.const_get :Unsuggest_str} <word>
  Suggest a word be removed from dictionary
HELP
      match(/#{self.const_get :Unsuggest_str}\s*(.*)/, method: :unsuggest)
    end
  end

end
