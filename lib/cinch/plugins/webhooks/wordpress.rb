module Cinch::Plugins
  class Webhooks
    #listen_to :github_hook, method: :github_hook

    class Server < Sinatra::Base
      post "/wordpress" do
        "WORDPRESS HOOK RECEIVED"
        puts params
        #event = request.env['HTTP_X_GITHUB_EVENT'].to_sym
        #return halt 202, "Ignored: #{event}" if ignored?(event, data)
        #self.class.bot.handlers.dispatch(:github_hook, nil, data, event)
        return halt 200
      end
    end
  end
end