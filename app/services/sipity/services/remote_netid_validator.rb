require 'open-uri'
module Sipity
  module Services
    # Responsible for determining if a given string is a valid NetID
    module RemoteNetidValidator
      module_function

      # @param [String] possible_netid
      # @return [false] if the input is not a valid NetID
      # @return [String] if the input is a valid NetID
      def valid_netid?(possible_netid)
        response = request(possible_netid)
        parse(response)
      rescue OpenURI::HTTPError
        false
      end

      def request(possible_netid)
        # Leveraging 'open-uri' and its easy to use interface
        open(url(possible_netid)).read
      end

      def parse(response)
        person = JSON.parse(response).fetch('people').first
        begin
          person.fetch('netid')
        rescue KeyError
          false
        end
      end

      def url(possible_netid)
        base_uri = URI.parse(Figaro.env.hesburgh_api_host!)
        base_uri.path = "/1.0/people/by_netid/#{possible_netid}.json"
        base_uri.query = "auth_token=#{Figaro.env.hesburgh_api_auth_token!}"
        base_uri.to_s
      end

      private_class_method :request, :parse, :url
    end
  end
end
