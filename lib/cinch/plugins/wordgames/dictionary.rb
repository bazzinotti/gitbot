class Dictionary
  attr_accessor :words, :filename

  def initialize(words)
    @words = words
    @filename = ""
  end

  def self.from_file(filename)
    words = []
    File.foreach(filename) do |word|
      #if word[0] == word[0].downcase
        words << word.strip.gsub(/'.*/, '').downcase
      #end
    end
    dict = self.new(words.uniq)
    dict.filename = filename
    dict
  end

  def random_word
    @words.sample
  end

  def word_valid?(word)
    @words.include? word
  end
end
