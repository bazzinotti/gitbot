require 'cinch'

module Cinch::Plugin
  def class_name
    self.class.name.split("::").last
  end
end
