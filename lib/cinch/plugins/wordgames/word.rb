class Word
  attr_accessor :word

  def initialize(word)
    @word = word
  end

  def before?(other_word)
    @word < other_word
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
