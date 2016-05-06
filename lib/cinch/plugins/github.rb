require 'cinch'
require 'net/http'
require 'json'
require "date"
require 'openssl'

module Cinch::Plugins
  class Github

    include Cinch::Plugin

    set :help, <<-HELP
ghrepo <user> <repo>
 	Provides link to <user>/<repo>
ghuser <user>
 	Sees if <user> exists, and if so provides URL
  	HELP

    Base_url = "https://api.github.com"

    match(/ghuser (\S+)/, method: :ghuser)
    match(/ghrepo (\S+) (\S+)/, method: :ghrepo)

    def not_found?(data)
    	data["message"] == "Not Found"
    end

    def ghuser(m, user)
    	uri = URI(Base_url + "/users/" + user)
			response = Net::HTTP.get(uri)
			data = JSON.parse(response)
			if not_found?(data)
				m.reply "#{user} not found =0"
				return
			end
      m.reply Cinch::Formatting.format(:silver,"#{user}") + " :: " + \
      				# Git.io.generate(data["html_url"])
      				data["html_url"]
    end

    def ghrepo(m, user, repo)
    	uri = URI(Base_url + "/repos/" + user + "/" + repo)
			response = Net::HTTP.get(uri)
			data = JSON.parse(response)
			if not_found?(data)
				m.reply "#{user}/#{repo} not found =0"
				return
			end
      m.reply Cinch::Formatting.format(:silver,"#{user}") + "/" + \
      				Cinch::Formatting.format(:teal,"#{repo}") + " :: " + \
      				# Git.io.generate(data["html_url"])
      				data["html_url"]
    end
  end
end

