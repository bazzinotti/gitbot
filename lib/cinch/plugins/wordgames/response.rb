class Response
  def initialize(output, game)
    @game = game
    @output = output
    @user = output.user
  end

  # put helper functions in here that return a string
  module Helper
    def limits
      lb = @game.lower_bound
      ub = @game.upper_bound
      "Limits: #{lb} <=> #{ub}. You've had #{game.number_of_guesses_phrase}."
    end
  end

  include Helper

  def game_not_started(prefix)
    output.reply(
      "I haven't started a word game yet. Use " \
      "`#{prefix}#{Cinch::Plugins::WordGame::Start_str}` to start one.")
  end

  def start_game(prefix)
    output.reply("Let's play! Make a `#{prefix}#{Cinch::Plugins::WordGame::Guess_str}`")
  end

  def game_won
    output.reply(
      "Yes, that's the word! Congratulations, #{user} wins! " \
      "You had #{game.number_of_guesses_phrase}.")
  end

  def autocheat
    output.reply(
      "That's #{game.number_of_guesses_phrase}!! " \
      "The word is #{game.word}. Nice try, losers!")
  end

  def cheat
    output.reply(
      "You want to cheat after #{game.number_of_guesses_phrase}? Fine. " \
      "The word is #{game.word}. #{user}: you suck.")
  end

  def wrong_word(before_or_after)
    output.reply(%Q{My word comes #{before_or_after} "#{game.last_guess}". #{limits}})
  end

  def invalid_word(word)
    output.reply(
      %Q{#{user}: "#{word}" isn't a word. At least as far as I know. } +
      limits)
  end

protected
  attr_reader :user, :output, :game
end