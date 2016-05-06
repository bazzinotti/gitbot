module Cinch::Plugins
  class Webhooks
    include Cinch::Plugin

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

      def self.submodule_init(name)
        orig_method = self.method(:init)
        self.define_singleton_method :init do |config|
          orig_method.call config
          name.config = config[name.to_s.split('::').last.to_sym]
        end
      end

      def self.init(config={})
        server_config = {
          :bind => "0.0.0.0",
          :port => "5651",
          :logging => false,
          :lock => true,
          :run => true,
          :traps => false
        }.merge(config[:Server])
  
        set server_config

        @config = config
      end

      get "/" do
        self.class.config.to_s
      end

      post '/' do
        self.class.bot.loggers.debug "Receiving JSON payload"
        
        ""
      end
    end

    def initialize(*args)
      super
      #puts config
      @sinatra_thread = Thread.new do
        Server.bot = @bot
        # () string keys into symbols ;)
        Server.init(config)
        Server.run!
      end
    end

    def unregister(*args)
      @sinatra_thread.kill
      super
    end
  end
end