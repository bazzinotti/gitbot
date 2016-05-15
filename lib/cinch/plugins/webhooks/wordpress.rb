require_relative '../utils/uri'

module Cinch::Plugins
  class Webhooks

    class Server < Sinatra::Base
      @submodule_name = "Wordpress"
      include Submodule

      module Wordpress
        # basically, only return true if the config explicitly sets active: false
        # lack of the value or parent key defaults to false
        def self.ignored?(event, data, blog_title)
          config_event = config[:blogs][blog_title][event]
          puts config_event
          return false if !config_event
          return false unless active = config_event.key?('active')
          return true if !config_event['active'] && !config_event['active'].nil?
          false
        end
      end
    end


    module Wordpress
      def self.included(by)
        by.instance_exec do
          listen_to :wordpress_hook, method: :wordpress_hook
        end
      end

      def wordpress_hook(m, blog_title, data, event, request)
        @wordpress.send "get_#{event}", blog_title, data, request
      end

      def initialize(*args)
        super

        @wordpress = Wordpress.new(config, @bot)

        c = config
        Server.class_eval do
          c[:Wordpress]['blogs'].each do |k, v|
            post v['path'] do
              puts params
              event = params['hook']
              data = params
              blog_title = k
              return halt 202, "Ignored: #{event}" if Server::Wordpress::ignored?(event, data, blog_title)
              self.class.bot.handlers.dispatch(
                :wordpress_hook, nil, blog_title, data, event, request)
              return halt 200
            end
          end
        end
      end

      class Wordpress
        include Submodule
        attr_reader :blog_title

        def fetch_title?
          config[:blogs][self.blog_title]['fetch_title']
        end

        def blog_channels(title)
          config[:blogs][self.blog_title]['channels']
        end

        ##############
        # IRC Output #
        ##############

        def say(title, msg)
          blog_channels(title).each do |c|
            @bot.Channel(c).send msg
          end
        end

        ##############
        # Formatting #
        ##############

        def format_blog_title(blog_title)
          Cinch::Formatting.format(:Black, '[') +
          Cinch::Formatting.format(:green, blog_title) +
          Cinch::Formatting.format(:Black, ']')
        end

        def format_blog_title_from_url(url)
          blog_title = Utils::URI.get_titles(url).split(' | ')[0]
          Cinch::Formatting.format(:Black, '[') +
            Cinch::Formatting.format(:green, blog_title) +
            Cinch::Formatting.format(:Black, ']')
        end

        def format_post_title(data)
          Cinch::Formatting.format(:teal, "#{data["post_title"]}")
        end

        def format_post_url(data)
          data['post_url']
        end

        def format_post_url_short(data)
          data['guid']
        end

        ### COMMENTS
        def format_comment_author(data)
          Cinch::Formatting.format(:silver, data['comment_author'])
        end

        #########
        # HOOKS #
        #########

        def get_comment_post(blog_title, data, request)
          puts "comment_post"
          @blog_title = blog_title
          # "[Blog title] New comment on Blog Post by Author @ URL"
          response = format_blog_title(blog_title)
          response << " New comment on \"#{}\""
          response << format_post_title(data)
          response << " @ " << format_post_url_short(data)

          say(blog_title, response)
        end

        def get_publish_page(blog_title, data, request)
          puts "publish_page"
          @blog_title = blog_title
        end

        #TODO
        ## compare post_modified_gmt and post_date_gmt to determine if a post
        ## has been created or is being updated
        def get_publish_post(blog_title, data, request)
          puts "publish_post"
          @blog_title = blog_title
          response = fetch_title? ?
            format_blog_title_from_url(request.env['HTTP_REFERER']) :
            format_blog_title(blog_title)
          response << " New blog post "
          response << format_post_title(data)
          response << " @ " << format_post_url_short(data)

          say(blog_title, response)
        end
      end
    end
    include Wordpress
  end
end