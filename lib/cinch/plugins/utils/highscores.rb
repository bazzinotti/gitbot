require 'cinch'
require_relative 'highscores_backend'

module Cinch::Plugins::Utils::Highscores
  # Database backend!!!
  include BackendRedis

  def self.included(by)
    by.instance_exec do
      match(/#{self.const_get :Highscores_str}\s*([0-9]*)/, method: :print_top_scores)
    end
  end
end
