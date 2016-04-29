require 'cinch'

module Cinch
  module Plugin
    module ClassMethods
      def enable_acl
        hook(:pre, :method => lambda {|m| check_acl(m)})
      end
    end

    def check_acl(m)
      @bot.yml_config["irc"]["plugins"].each do |k, v|
        if v && v.has_key?("exclude") && self.class.plugin_name == k.downcase
            v["exclude"].each { |c| return false if m.channel.to_s == c }
        end
      end
    end
  end
end

# This is so Plugin Classes can access the prefix configuration and create
# custom 'match' cases or custom 'set :prefix' with it.
module Cinch
  module Plugins
    class << self
      attr_accessor :prefix   # Written from config-load routine
    end
  end
end