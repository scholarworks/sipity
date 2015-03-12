module Sipity
  module Services
    class NoidMinter
      def initialize(configuration)
        configuration = {
            host: Figaro.env.noid_server!,
            port: Figaro.env.noid_port!
        }
        @service ||= ::NoidsClient::Connection.new(@server).get_pool(@pool)
      end

      # Returns a single NOID
      def call
      end
    end
  end
end