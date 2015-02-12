require 'net/ldap'
module Sipity
  module Services
    # This class querries LDAP to get user information
    class LdapClient
      attr_reader :net_id, :connection

      LDAP_TIME_OUT = 15

      # The ldap_options is a hash containing
      # :host, :port, :encryption and :base
      def initialize(net_id, ldap_options)
        @net_id = net_id
        @connection = Net::LDAP.new(ldap_options)
      end

      def netid_valid?
        ldap_lookup ? true : false
      end

      # Custom error class
      class UserNotFoundError < RuntimeError
        def initialize(error_message)
          super(error_message)
        end
      end

      private

      def ldap_lookup
        results = connection.search(
                      attributes: ['uid', 'mail', 'displayName'],
                      filter: Net::LDAP::Filter.eq('uid', net_id),
                      return_result: true
        )

        return nil if results.blank?
        results.first
      end

      def ldap_query
        Timeout.timeout(LDAP_TIME_OUT) do
          if !(result = ldap_lookup).blank?
            return result
          else
            fail UserNotFoundError, "User: #{net_id} is not found."
          end
        end
      end
    end
  end
end
