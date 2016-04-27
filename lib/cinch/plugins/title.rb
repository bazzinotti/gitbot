require 'cinch'
require 'open-uri'
require 'nokogiri'

class Cinch::Plugins::Title
  include Cinch::Plugin

  set :prefix, /^[^!]/

  match(/.*/)
  def execute(m)
    urls = URI.extract m.message
    if urls.any?
      titles = urls.collect { |url|
        begin
          Nokogiri::HTML(open(url), nil, 'utf-8').title.gsub(/(\r\n?|\n|\t)/, "")
        rescue => e
          puts "Error fetching title: #{e}"
        end
      }.keep_if { |t| t.length > 0 }
      if titles.any?
        m.reply "Link: #{titles.join(' || ')}"
      end
    end
  end
end

