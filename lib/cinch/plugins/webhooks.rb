require 'cinch'
require 'net/http'
require 'json'
require 'sinatra/base'
require "date"
require 'openssl'

require_relative 'webhooks/webhooks'
require_relative 'webhooks/github'
require_relative 'webhooks/wordpress'