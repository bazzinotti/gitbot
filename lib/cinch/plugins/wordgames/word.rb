# A class for operating with words
class Word
  def initialize(word)
    @word = word
  end

  def before?(other_word)
    @word < other_word
  end

  def after?(other_word)
    @word > other_word
  end

  def ==(other_word)
    @word == other_word
  end

  def to_s
    @word
  end
end
