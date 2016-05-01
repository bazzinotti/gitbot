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
        words << word.strip.gsub(/'.*/, '')
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

class Word
  attr_accessor :word

  def initialize(word)
    @word = word
  end

  def before?(other_word)
    @word < other_word.downcase
  end

  def before_or_after(other_word)
    before?(other_word) ? "before" : "after"
  end

  def ==(other_word)
    @word == other_word
  end

  def to_s
    @word
  end
end
