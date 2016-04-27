require 'net/http'

module Git
  module IO
    URL = URI 'https://git.io'

    class Error < RuntimeError; end

    instance_eval do
      def generate(url, code = nil)
        handle_response Net::HTTP.post_form(URL, 'url' => url, 'code' => code), Net::HTTPSuccess
      end

      def recognize(url)
        raise Error, 'Invalid git.io short url' unless %r/^#{URL}/ === url
        handle_response Net::HTTP.get_response(URI(url)), Net::HTTPRedirection
      end

      private

      def handle_response(response, expected_response_type)
        if expected_response_type === response
          response['Location']
        else
          raise Error, response.body
        end
      end
    end
  end

  def self.io; IO end
end
