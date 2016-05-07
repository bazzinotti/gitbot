require 'cinch'
require_relative 'utils/uri'

module Cinch
  module Plugins
    class Title
      include Cinch::Plugin

      set :prefix, /^[^#{Cinch::Plugins.prefix}]/

      match(/.*/)
      def execute(m)
        titles = Utils::URI.get_titles(m.message)
        m.reply "Link: #{titles}" if titles
      end
    end
  end
end

