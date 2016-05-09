require 'cinch'
require "yaml"
require_relative 'plugin_override.rb'

module Ayumi
  class Bot < Cinch::Bot
    def initialize(config_file)
      super() do
        configure do |c|
          config = YAML.load_file config_file
          @yml_config = config

          rconf = {}
          config["redis"].each { |k, v| rconf[k.to_sym] = v }

          @redis = Redis.new({:host => "localhost", :port => 6379}.merge(rconf))
          Bazz::Utils::Redis.redis = @redis

          configure do |c|
            config = config["irc"]
            c.nick = config["nick"]
            c.password = config["password"]
            c.user = config["user"]
            c.realname = config["realname"]
            c.server = config["server"]
            c.port = config["port"]
            mappings = {}
            c.channels = config["channels"].map! do |chan|
              mappings[chan] = chan + ENV['GITBOT_IRC_CHAN_EXT'].to_s # config["channel-ext"]
            end
            #remap_chanfilters(config["plugins"]["Github"]["options"]["filters"], mappings)
            c.messages_per_second = config['messages_per_second'] if config['messages_per_second']
            c.server_queue_size = config['server_queue_size'] if config['server_queue_size']

            prefix = config["prefix"] || '!'
            c.plugins.prefix = prefix
            Cinch::Plugins.prefix = prefix

            config["plugins"].each do |k, v|
              require_relative "../cinch/plugins/" + Bazz::Utils::Class.class_name_to_file_name(k)
              cls = Cinch::Plugins.const_get(k)
              c.plugins.plugins << cls

              if v && v.has_key?("options")
                o = {}
                v["options"].each { |k, v| o[k.to_sym] = v }
                c.plugins.options[cls] = o
              end

              cls.enable_acl
            end
          end
        end
        @last_refresh = Time.new
      end
    end

    attr_reader :yml_config

    def redis=(redis) @redis = redis end

    def redis() @redis end

    def admins
      @admins ||= @yml_config['irc']['admins']
    end

    def admin?(user)
      time = Time.new
      if time > (@last_refresh + 10)
        puts "refreshing\n"
        user.refresh
        @last_refresh = time
      end
      admins.include?(user.authname)
    end

    # def remap_chanfilters(cf, mappings)
    #   cf.keys.each { |k| cf[mappings[k]] = cf.delete(k) if mappings[k] }
    # end

  end
end