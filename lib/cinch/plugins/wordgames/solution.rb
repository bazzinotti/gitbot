class Solution
  attr_accessor :word

  def initialize(word)
    @word = word
  end

  def before?(guess)
    @word < guess
  end

  # this function is no longer used and should be removed soonish
  def before_or_after(guess)
    before?(guess) ? "before" : "after"
  end

  def ==(guess)
    @word == guess
  end

  def to_s
    @word
  end
end
