require 'cinch'

module Cinch
  module Plugins
    class Say
      include Cinch::Plugin

      match /say (\S+) (.+)/

      # Tell the bot to say something in another channel. Especially useful from
      # private messages so nobody knows what's going on.
      #
      # <davidcelis> !say #freenode I HAVE ACHIEVED SELF AWARENESS.
      # <snap> I HAVE ACHIEVED SELF AWARENESS.
      # * ChanServ sets mode +o on evilmist
      # * evilmist sets mode +b on snap
      def execute(m, channel, message)
        Channel(channel).send(message) if @bot.admin?(m.user)
      end

      match(/action (\S+) (.+)/, method: :action)
      def action(m, channel, message)
        Channel(channel).action(message) if @bot.admin?(m.user)
      end
    end
  end
end
