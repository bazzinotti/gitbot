require 'cinch'

require_relative 'dict_word.rb'
require_relative 'response.rb'


module Cinch::Plugins::WordGames
  class Game
    attr_reader :number_of_guesses, :last_guess, :word

    def initialize(dictionary)
      @dict = dictionary
      @word = Word.new(@dict.random_word)
      puts "Word is #{@word}"
      @number_of_guesses = 0
    end

    def guess(word, response)
      @number_of_guesses += 1
      @last_guess = word
      if @dict.word_valid?(word)
        guess_correct?(word, response)
      else
        response.invalid_word
        false
      end
    end

    def number_of_guesses_phrase
      if number_of_guesses == 1
        "1 guess"
      else
        "#{number_of_guesses} guesses"
      end
    end

  protected
    def guess_correct?(word, response)
      if @word == word
        response.game_won
        true
      else
        response.wrong_word(@word.before_or_after(word))
        false
      end
    end
  end
end
