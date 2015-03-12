module Sipity
  module Services
    class NoidMinter
      def initialize(configuration)
        configuration = {
            host: Figaro.env.noid_server!,
            port: Figaro.env.noid_port!
        }
        new(configuration).call
      end

      # The ldap_options is a hash containing
      # :host, :port, :encryption and :base
      def initialize(noid_options)
        @connection = ::NoidsClient::Connection.new(noid_options.fetch[:server])
                      .get_pool(noid_options.fetch[:pool])
      end

      def template
        @template ||= connection.template.split("+").first
      end

      # Returns a single NOID
      def call
      end
    end
  end
end