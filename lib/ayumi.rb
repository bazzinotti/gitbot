$:.unshift File.dirname(__FILE__)

require "cinch"
require 'redis'
require 'bazz/utils/class'
require 'bazz/utils/redis'
require 'bazz/utils/scores'

require 'ayumi/bot.rb'

require 'cinch/plugins/word_game.rb'
