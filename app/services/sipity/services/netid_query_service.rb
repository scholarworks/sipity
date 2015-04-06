require 'open-uri'
module Sipity
  module Services
    # Responsible for querying people API server to get more details for netid
    class NetidQueryService
      def self.call(netid:)
        new(netid)
      end

      def self.preferred_name(netid:)
        new(netid).preferred_name
      end

      def initialize(netid)
        @netid = netid
      end
      attr_reader :netid

      # @return [nil] if the input is not a valid NetID
      # @return [String] if the input is a valid NetID
      def preferred_name
        person.fetch('full_name')
      rescue KeyError
        netid
      end

      private

      def person
        parse
      rescue OpenURI::HTTPError
        {}
      end

      def response
        # Leveraging 'open-uri' and its easy to use interface
        open(url).read
      end

      def parse
        JSON.parse(response).fetch('people').first
      end

      def url
        base_uri = URI.parse(Figaro.env.hesburgh_api_host!)
        base_uri.path = "/1.0/people/by_netid/#{netid}.json"
        base_uri.query = "auth_token=#{Figaro.env.hesburgh_api_auth_token!}"
        base_uri.to_s
      end
    end
  end
end
