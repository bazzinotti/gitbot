require 'cinch'
require 'net/http'
require 'json'
require 'sinatra/base'
require_relative 'git-io'

module Cinch::Plugins
  class Github
    class Server < Sinatra::Base

      def self.bot
        @bot
      end

      def self.bot=(bot)
        @bot = bot
      end

      def self.config
        @config
      end

      def self.config=(config)
        @config = config
      end

      def self.init(config={})
        config = {:bind => "0.0.0.0", :port => "5651", :logging => false, :lock => true, :run => true, :traps => false}.merge(config)
  
        set config

        @config = config
      end

      get "/" do
        ""
      end

      post "/github" do
        request.body.rewind
        payload_body = request.body.read
        #verify_signature(payload_body) if self.class.config.key?(:secret)
        data = JSON.parse(params[:payload])
        event = request.env['HTTP_X_GITHUB_EVENT'].to_sym
        return halt 202, "Ignored: #{event}" if ignored?(event, data)
        self.class.bot.handlers.dispatch(:github_hook, nil, data, event)
        return halt 200
  
      end

      post '/' do
        self.class.bot.loggers.debug "Receiving JSON payload"
        
        ""
      end

      ################
      # Verification #
      ################

      def verify_signature(payload_body)
        signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), self.class.config[:secret], payload_body)
        return halt 500, "Signature mosmatch" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
      end

      def ignored?(event, data)
        return false unless self.class.config[:ignore] && self.class.config[:ignore].key?(event)
        return true if self.class.config[:ignore][event].empty?
        match = (event == 'create' || event == 'delete') ? :ref_type : :action
        return true if self.class.config[:ignore][event].include? data[match]
        false
      end
    end

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

    listen_to :github_hook, method: :github_hook

    def not_found(data)
    	data["message"] == "Not Found"
    end

    def ghuser(m, user)
    	uri = URI(Base_url + "/users/" + user)
			response = Net::HTTP.get(uri)
			data = JSON.parse(response)
			if not_found(data)
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
			if not_found(data)
				m.reply "#{user}/#{repo} not found =0"
				return
			end
      m.reply Cinch::Formatting.format(:silver,"#{user}") + "/" + \
      				Cinch::Formatting.format(:teal,"#{repo}") + " :: " + \
      				# Git.io.generate(data["html_url"])
      				data["html_url"]
    end

    def initialize(*args)
      super

      @sinatra_thread = Thread.new do
        Server.bot = @bot
        Server.init(config)
        Server.run!
      end
    end

    def unregister(*args)
      @sinatra_thread.kill
      super
    end

    def github_hook(m, data, event)
      send "get_#{event}", data
    end

    ##############
    # IRC Output #
    ##############

    def say(repo,msg)
      @bot.config.channels.each do |chan|
        unless config[:filters].include? chan and not config[:filters][chan].include? repo
          @bot.Channel(chan).send msg
        end
      end
    end

    ##############
    # Formatting #
    ##############

    ## TODO: Combine these where possible

    def format_repo(data)
      Cinch::Formatting.format(:green, "#{data["repository"]["name"]}")
    end

    def format_author(data)
      Cinch::Formatting.format(:silver, "#{data["sender"]["login"]}")
    end

    def format_branch(data)
      Cinch::Formatting.format(:orange, "#{data["ref"].gsub(/^refs\/heads\//,"")}")
    end

    def format_commit(c)
      Cinch::Formatting.format(:grey, "#{c["id"][0..7]}")
    end

    def format_cauthor(c)
      Cinch::Formatting.format(:silver, "#{c["author"]["username"]}")
    end

    def format_prauthor(data)
      format_author(data)
    end

    def format_prtitle(data)
      Cinch::Formatting.format(:teal, "#{data["pull_request"]["title"]}")
    end

    def format_prnumber(data)
      Cinch::Formatting.format(:orange, "##{data["pull_request"]["number"]}")
    end

    def format_prhead(data)
      Cinch::Formatting.format(:red, "#{data["pull_request"]["head"]["ref"]}")
    end

    def format_prbase(data)
     Cinch::Formatting.format(:red, "#{data["pull_request"]["base"]["ref"]}")
    end

    def format_issuenumber(data)
      Cinch::Formatting.format(:orange, "##{data["issue"]["number"]}")
    end

    def format_issuetitle(data)
      Cinch::Formatting.format(:teal, "#{data["issue"]["title"]}")
    end

    def format_ref(data)
      Cinch::Formatting.format(:orange, "#{data["ref"]}")
    end

    def format_ref_type(data)
      Cinch::Formatting.format(:teal, "#{data["ref_type"]}")
    end

    def format_stargazers_count(data)
      Cinch::Formatting.format(:orange, "#{data["repository"]["stargazers_count"]}")
    end

    #####################
    # Git.io generation #
    #####################

    ## TODO: Combine these

    def format_commiturl(data)
      Git.io.generate data["compare"]
    end

    def format_prurl(data)
      Git.io.generate data["pull_request"]["html_url"]
    end

    def format_issueurl(data)
      Git.io.generate data["issue"]["html_url"]
    end

    def format_commenturl(data)
      Git.io.generate data["comment"]["html_url"]
    end

    def format_releaseurl(data)
      Git.io.generate data["release"]["html_url"]
    end

    ##################
    # Received Hooks #
    ##################

    ## TODO: Add more hooks, add placeholders, consolidate repo variable

    def get_ping(data)
    end

    # the Github Webhook API only notifies when a user starts a stargaze
    def get_watch(data)
      repo = data["repository"]["name"]

      say repo, "#{Cinch::Formatting.format(:Black, '[')}" + format_repo(data) + \
                "#{Cinch::Formatting.format(:Black, ']')} " + format_author(data) + \
                " #{data["action"]} stargazing. Total: " + format_stargazers_count(data)
    end

    #------------------------------
    def format_commit_id(data)
      Cinch::Formatting.format(:grey, "#{data["comment"]["commit_id"][0..7]}")
    end

    def format_path(data)
      Cinch::Formatting.format(:teal, "#{data["comment"]["path"]}")
    end

    def get_commit_comment(data)
      repo = data["repository"]["name"]

      say repo, "#{Cinch::Formatting.format(:Black, '[')}" + format_repo(data) + \
                "#{Cinch::Formatting.format(:Black, ']')} " + format_author(data) + \
                " #{data["action"]} commit comment on " + \
                format_commit_id(data) + ":" + \
                format_path(data) + " @ " + format_commenturl(data)
    end

    def get_pull_request_review_comment(data)
      repo = data["repository"]["name"]

      say repo, "#{Cinch::Formatting.format(:Black, '[')}" + format_repo(data) + \
                "#{Cinch::Formatting.format(:Black, ']')} " + format_author(data) + \
                " #{data["action"]} diff comment on pull request " + format_prnumber(data) + ": " + \
                format_prtitle(data) + " (" + format_prhead(data) + " \u{2192} " + \
                format_prbase(data) + "):" + format_path(data) + " @ " + format_commenturl(data)
    end
    #------------------------------

    def create_delete_common(data, action)
      repo = data["repository"]["name"]
      say repo, "#{Cinch::Formatting.format(:Black, '[')}" + format_repo(data) + \
                "#{Cinch::Formatting.format(:Black, ']')} " + format_author(data) + \
                " #{action} " + format_ref_type(data) + " " + format_ref(data)
    end

    def get_create(data)
      create_delete_common(data, "created")
    end

    def get_delete(data)
      create_delete_common(data, "deleted")
    end

    #------------------------------
    # {opened,closed,reopened} issue
    def get_issues(data)
      repo = data["repository"]["name"]

      say repo, "#{Cinch::Formatting.format(:Black, '[')}" + format_repo(data) + \
                "#{Cinch::Formatting.format(:Black, ']')} " + format_author(data) + \
                " #{data["action"]} issue " + format_issuenumber(data) + ": " + \
                format_issuetitle(data) + " @ " + format_issueurl(data)
    end

    # {created, edited, deleted} issue_comment
    def get_issue_comment(data)
      repo = data["repository"]["name"]
      say repo, "#{Cinch::Formatting.format(:Black, '[')}" + format_repo(data) + \
                "#{Cinch::Formatting.format(:Black, ']')} " + format_author(data) + \
                " #{data["action"]} comment on #{data["issue"].has_key?("pull_request") ? 'pull request' : 'issue'} " + \
                format_issuenumber(data) + ": " + \
                format_issuetitle(data) + " @ " + format_commenturl(data)
    end

    def get_pull_request(data)
      repo = data["repository"]["name"]

      say repo, "#{Cinch::Formatting.format(:Black, '[')}" + format_repo(data) + \
                "#{Cinch::Formatting.format(:Black, ']')} " + format_prauthor(data) + \
                " #{data["action"]} pull request " + format_prnumber(data) + ": " + \
                format_prtitle(data) + " (" + format_prhead(data) + " \u{2192} " + \
                format_prbase(data) + ") @ " + format_prurl(data)
    end

    def get_push(data)
      repo = data["repository"]["name"]

      if data["created"] || data["deleted"]
        # get_create / get_delete already handle this

        #action = data["created"] ? "created" : "deleted"
        #say repo, "#{Cinch::Formatting.format(:Black, '[')}" + format_repo(data) + \
        #        "#{Cinch::Formatting.format(:Black, ']')} " + format_author(data) + \
        #        " #{action} " + format_ref(data)
        return
      end

      # sort commits by timestamp
      data["commits"].sort! do |a,b|
        ta = tb = nil
        begin
          ta = DateTime.parse(a["timestamp"])
        rescue ArgumentError
          ta = Time.at(a["timestamp"].to_i)
        end

        begin
          tb = DateTime.parse(b["timestamp"])
        rescue ArgumentError
          tb = Time.at(b["timestamp"].to_i)
        end

        ta <=> tb
      end

      # output first 5 commits
      say repo, "#{Cinch::Formatting.format(:Black, '[')}" + format_repo(data) + \
                "#{Cinch::Formatting.format(:Black, ']')} " + format_author(data) + \
                " pushed #{data["commits"].length} new commit#{data["commits"].count == 1 ? '' : 's'} to " + \
                format_branch(data) + ": " + format_commiturl(data)
      data["commits"][0..4].each do |c|
        message = c["message"]

        if message.include? "\n\n"
          message1, match, message2 = message.rpartition(/\n\n/)
        else
          message1 = message
        end

        say repo, " " + format_repo(data) + "/" + format_branch(data) + " " + format_commit(c) + " " + format_cauthor(c) + ": #{message1}"
      end

      if data["commits"].length-5 > 0
        say repo, format_repo(data) + "/" + format_branch(data) + " ...and #{data["commits"].length-5} more @ " +  + format_commiturl(data)
      end

    ## Debugging
    #  data.inspect
    end

    # ----------------------
    def format_release_author(data)
      format_author(data)
    end

    def format_release_tag_name(data)
      Cinch::Formatting.format(:orange, "#{data["release"]["tag_name"]}")
    end

    def format_release_name(data)
      Cinch::Formatting.format(:teal, "#{data["release"]["name"]}")
    end

    def get_release(data)
      repo = data["repository"]["name"]

      say repo, "#{Cinch::Formatting.format(:Black, '[')}" + format_repo(data) + \
                "#{Cinch::Formatting.format(:Black, ']')} " + format_release_author(data) + \
                " #{data["action"]} release " + format_release_tag_name(data) + " " + \
                format_release_name(data) + " @ " + format_releaseurl(data)
    end
  end
end

