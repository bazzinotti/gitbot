$:.unshift File.dirname(__FILE__)

require "cinch"
require 'redis'
require 'bazz/utils/redis.rb'
require 'bazz/utils/scores.rb'

require 'ayumi/bot.rb'