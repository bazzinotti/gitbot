require 'cinch'
require 'open-uri'
require 'nokogiri'

module Cinch::Plugins
  module Utils
    module URI
      def self.get_titles(m) # m == string
        urls = ::URI.extract m
        p urls
        if urls.any?
          titles = urls.collect { |url|
            begin
              Nokogiri::HTML(open(url), nil, 'utf-8').title.gsub(/(\r\n?|\n|\t)/, "")
            rescue => e
              puts "Error fetching title: #{e}"
              return
            end
          }.keep_if { |t| t.length > 0 }
          if titles.any?
            "#{titles.join(' || ')}"
          end
        end
      end
    end
  end
end
