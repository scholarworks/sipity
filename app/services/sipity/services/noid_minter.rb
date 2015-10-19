module Sipity
  module Services
    # This module uses noid client to mint a pid
    module NoidMinter
      module_function

      def call
        connection.mint.first
      end

      def connection(env: Figaro.env)
        return @connection if @connection.present?
        server = env.noid_server!
        port = env.noid_port!.to_i
        pool = env.noid_pool!
        @connection = ::NoidsClient::Connection.new("#{server}:#{port}").get_pool(pool)
      end
    end
  end
end
