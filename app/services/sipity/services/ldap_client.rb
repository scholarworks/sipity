require 'net/ldap'
module Sipity
  module Services
    # This class querries LDAP to get user information
    class LdapClient
      def self.valid_netid?(netid)
        configuration = {
          host: Figaro.env.ldap_host!,
          port: Figaro.env.ldap_port!,
          encryption: Figaro.env.ldap_encryption!.to_sym
        }
        new(configuration).valid_netid?(netid)
      end

      attr_reader :connection

      # The ldap_options is a hash containing
      # :host, :port, :encryption and :base
      def initialize(ldap_options)
        @connection = Net::LDAP.new(ldap_options)
      end

      def valid_netid?(netid)
        ldap_entry_for(netid: netid).present?
      end

      private

      def ldap_entry_for(netid:)
        Array.wrap(
          connection.search(
            attributes: ['uid', 'mail', 'displayName'],
            filter: Net::LDAP::Filter.eq('uid', netid),
            return_result: true
          )
        ).first
      end
    end
  end
end
