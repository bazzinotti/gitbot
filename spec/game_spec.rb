require 'spec_helper'

describe "game" do

  describe "Guess!" do
    before :each do
      dictionary = Dictionary.new %w(apple banana cheese danish egg fry)
      @game = Cinch::Plugins::Game.new(dictionary,dictionary, solution: "banana")
    end

    it "can tell when you guess too high" do
      expect(@game.guess!("apple")).to eql(:missed_north)
    end

    it "can tell when you guess too low" do
      expect(@game.guess!("cheese")).to eql(:missed_south)
    end

    it "can tell when you guess something not a word" do
      expect(@game.guess!("thuslymuchly")).to eql(:not_a_word)
    end

    it "can tell when you guess the solution" do
      expect(@game.guess!("banana")).to eql(:correct)
    end
  end

end
