require 'cinch'
require_relative 'scores'
require_relative 'highscores_backend'

module Cinch::Plugins::Utils::HighScores
  Driver = Redis
  attr_reader :highscores

  def initialize(*args)
    super
    @highscores = Driver.new(self)
  end

  # purely a hack for the matcher
  # the matcher needs a class-level instance function
  # but I really want to call an instance variable function
  # but I can't call it directly since the instance variable does not exist
  # at the time of "matcher creation"
  def print_highscores(m, n)
    self.highscores.print_highscores(m, n)
  end

  def self.included(by)
    by.instance_exec do
      self.help << <<-HELP
#{self.const_get :Highscores_str} <num=5>
  Print the top <num> high scores.
HELP

      match(/#{self.const_get :Highscores_str}\s*([0-9]*)/, method: :print_highscores)
    end
  end
end
