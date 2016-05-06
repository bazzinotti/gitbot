module Cinch::Plugins
  class Webhooks
    include Cinch::Plugin

    module SubmoduleClassMethods
      def submodule_name
        @submodule_name
      end
    end

    extend SubmoduleClassMethods

    module Submodule
      def initialize(config, bot)
        @config = config[self.class.name.to_s.split('::').last.to_sym] ? config[self.class.name.to_s.split('::').last.to_sym].inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo} : {}
        puts "DERPERPEPRPE\n#{@config}"
        @bot = bot
      end

      def config
        @config
      end
    end


    class Server < Sinatra::Base
      extend SubmoduleClassMethods

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
        puts "INIT"
        server_config = {
          :bind => "0.0.0.0",
          :port => "5651",
          :logging => false,
          :lock => true,
          :run => true,
          :traps => false
        }.merge(config[:Server])

        puts config
  
        set server_config

        @config = config
      end

      def self.submodule_init(name)
        puts self
        orig_method = self.method(:init)
        self.define_singleton_method :init do |config|
          orig_method.call config
          name_var = self.const_get(name)
          name_var.config = config[name.to_sym].inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
        end
      end

      module Submodule
        def self.included(server)
          mod = Module.new do
            class << self
              attr_accessor :config
            end
          end
          server.const_set(server.submodule_name.to_sym, mod)
          server.submodule_init(server.submodule_name)
        end
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
      puts "INITIALIZE"
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