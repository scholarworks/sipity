module Sipity
  module Services
    # This module uses noid client to mint a pid
    module NoidMinter
      module_function

      def call
        connection.mint.first
      end

      def connection
        return @connection if @connection.present?
        server = Figaro.env.noid_server!
        port = Figaro.env.noid_port!.to_i
        pool = Figaro.env.noid_pool!
        @connection = ::NoidsClient::Connection.new("#{server}:#{port}").get_pool(pool)
      end
    end
  end
end
