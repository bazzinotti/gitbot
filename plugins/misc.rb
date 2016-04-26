require 'cinch'

module Cinch
  module Plugins
    class Misc
      include Cinch::Plugin

      listen_to :join
      # listen_to :leaving, method: :left

      def listen(m)
        #return if m.user == @bot
        return unless @bot.admin?(m.user)
        
        m.action_reply "waves to #{m.user} :)"
      end

      # def left(m, user)
      #   return if m.user == @bot

      #   m.reply "Goodbye #{user}"
      # end
    end
  end
end
