# Copyright (c) 2010 Emil Loer
# Copyright (c) 2016 Michael Bazzinotti

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


require_relative 'git-io'
# require 'pry'

module Cinch::Plugins
  class Webhooks
    class Server < Sinatra::Base
      post "/github" do
        request.body.rewind
        payload_body = request.body.read
        #Github.verify_signature(payload_body) if self.class.config.key?(:secret)
        data = JSON.parse(params[:payload])
        event = request.env['HTTP_X_GITHUB_EVENT'].to_sym
        return halt 202, "Ignored: #{event}" if Github.ignored?(event, data)
        self.class.bot.handlers.dispatch(:github_hook, nil, data, event)
        return halt 200
      end

      @submodule_name = "Github"
      include Submodule

      module Github
        ################
        # Verification #
        ################

        def self.verify_signature(payload_body)
          signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), config[:secret], payload_body)
          return halt 500, "Signature mismatch" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
        end

        def self.ignored?(event, data)
          return false unless config[:ignore] && config[:ignore].key?(event)
          return true if config[:ignore][event].empty?
          match = (event == 'create' || event == 'delete') ? :ref_type : :action
          return true if config[:ignore][event].include? data[match]
          false
        end
      end
    end

    module Github
      def self.included(by)
        by.instance_exec do
          listen_to :github_hook, method: :github_hook
        end
      end

      def github_hook(m, data, event)
        @github.send "get_#{event}", data
      end

      def initialize(*args)
        super

        @github = Github.new(config, @bot)
      end

      class Github
        include Submodule
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

    include Github
  end
end