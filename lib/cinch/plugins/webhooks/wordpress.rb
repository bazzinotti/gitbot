# TODO
## Ignore events
## Comment Event
## Post Event
## Page event
## Config mapping path => blog_title


module Cinch::Plugins
  class Webhooks

    class Server < Sinatra::Base
      post "/wordpress" do
        puts params
        event = params['hook']
        data = params
        blog_title = "SNES Tracker"
        #return halt 202, "Ignored: #{event}" if Wordpress.ignored?(event, data)
        self.class.bot.handlers.dispatch(:wordpress_hook, nil, blog_title, data, event)
        return halt 200
      end

      @submodule_name = "Wordpress"
      include Submodule

      module Wordpress
        def self.ignored?(event, data)
          return false unless config[:ignore] && config[:ignore].key?(event)
          return true if config[:ignore][event].empty?
          match = (event == 'create' || event == 'delete') ? :ref_type : :action
          return true if config[:ignore][event].include? data[match]
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

      def wordpress_hook(m, blog_title, data, event)
        @wordpress.send "get_#{event}", blog_title, data
      end

      def initialize(*args)
        super

        @wordpress = Wordpress.new(config, @bot)
      end

      class Wordpress
        include Submodule

        ##############
        # IRC Output #
        ##############

        def say(repo,msg)
          # @bot.config.channels.each do |chan|
          #   unless config[:filters].include? chan and not config[:filters][chan].include? repo
          #     @bot.Channel(chan).send msg
          #   end
          # end
        end

        #########
        # HOOKS #
        #########

        def get_comment_post(blog_title, data)
          puts "comment_post"
        end

        def get_publish_page(blog_title, data)
          puts "publish_page"
        end

        def get_publish_post(blog_title, data)
          puts "publish_post"
        end
      end
    end
    include Wordpress
  end
end