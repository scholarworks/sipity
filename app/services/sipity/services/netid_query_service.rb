require 'open-uri'
module Sipity
  module Services
    # Responsible for querying people API server to get more details for netid
    class NetidQueryService
      def self.preferred_name(netid)
        new(netid).preferred_name
      end

      def self.valid_netid?(netid)
        new(netid).valid_netid?
      end

      def initialize(netid)
        self.netid = netid
      end

      attr_reader :netid

      private

      def netid=(input)
        @netid = input.to_s.strip
      end

      public

      # @return [netid] if the input is not a valid NetID
      # @return [String] if the input is a valid NetID
      def preferred_name
        person.fetch('full_name')
      rescue KeyError
        netid
      end

      # @return [false] if the input is not a valid NetID
      # @return [String] if the input is a valid NetID
      def valid_netid?
        person.fetch('netid')
      rescue KeyError
        false
      end

      private

      def person
        return {} unless netid.present?
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

      def url(env: Figaro.env)
        base_uri = URI.parse(env.hesburgh_api_host!)
        base_uri.path = "/1.0/people/by_netid/#{netid}.json"
        base_uri.query = "auth_token=#{env.hesburgh_api_auth_token!}"
        base_uri.to_s
      end
    end
  end
end
