require_relative 'suggestions_backend'

module Cinch::Plugins
  module Utils
    module Unsuggestions
      class Redis < Suggestions::Redis
        def suggestions_table
          "#{@owner.class.plugin_name}:unsuggestions"
        end
      end
    end
  end
end
