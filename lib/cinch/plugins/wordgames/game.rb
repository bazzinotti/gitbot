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
      @solution = Word.new(@dict.random_word)
      @number_of_guesses = 0
      @lower_bound = Blank_str
      @upper_bound = Blank_str
    end

    def guess!(word)
      @number_of_guesses += 1
      evaluate_guess!(word)
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

    def evaluate_guess!(word)
      if !@dict.word_valid?(word) && !@ref_dict.word_valid?(word)
        :not_a_word
      elsif @solution == word
        :correct
      else
        if @solution.before?(word)
          @upper_bound = word if blank?(@upper_bound) || word < @upper_bound
          :missed_south
        else
          @lower_bound = word if blank?(@lower_bound) || word > @lower_bound
          :missed_north
        end
      end
    end

  end
end
