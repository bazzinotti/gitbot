require 'cinch'

require_relative 'dictionary.rb'
require_relative 'solution.rb'
require_relative 'response.rb'

module Cinch::Plugins
  class Game
    attr_reader :number_of_guesses, :lower_bound, :upper_bound, :solution
    Blank_str = "__"

    def initialize(dictionary, ref_dict)
      @dict = dictionary
      @ref_dict = ref_dict
      @solution = Solution.new(@dict.random_word)
      puts "Word is #{@solution}"
      @number_of_guesses = 0

      @lower_bound = Blank_str
      @upper_bound = Blank_str
    end

    def guess(word, response)
      @number_of_guesses += 1
      if @dict.word_valid?(word) || @ref_dict.word_valid?(word)
        guess_correct?(word, response)
      else
        response.invalid_word(word)
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
    def blank?(bound)
      bound == Blank_str
    end

    def guess_correct?(word, response)
      if @solution == word
        response.game_won
        true
      else
        if @solution.before?(word)
          @upper_bound = word if blank?(@upper_bound) || word < @upper_bound
        else
          @lower_bound = word if blank?(@lower_bound) || word > @lower_bound
        end
        response.wrong_word(@solution.before_or_after(word), word)
        false
      end
    end

  end
end
