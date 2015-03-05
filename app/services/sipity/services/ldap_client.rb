require 'net/ldap'
module Sipity
  module Services
    # This class querries LDAP to get user information
    class LdapClient
      attr_reader :connection

      LDAP_TIME_OUT = 15

      # The ldap_options is a hash containing
      # :host, :port, :encryption and :base
      def initialize(ldap_options)
        @connection = Net::LDAP.new(ldap_options)
      end

      def valid_netid?(netid)
        ldap_entry_for(netid: netid).present?
      end

      # Custom error class
      class UserNotFoundError < RuntimeError
        def initialize(error_message)
          super(error_message)
        end
      end

      private

      def ldap_entry_for(netid:)
        results = connection.search(
                      attributes: ['uid', 'mail', 'displayName'],
                      filter: Net::LDAP::Filter.eq('uid', netid),
                      return_result: true
        )
        return nil if results.blank?
        results.first
      end

      def ldap_query
        Timeout.timeout(LDAP_TIME_OUT) do
          result = ldap_lookup
          if result.present?
            return result
          else
            fail UserNotFoundError, "User: #{net_id} is not found."
          end
        end
      end
    end
  end
end
