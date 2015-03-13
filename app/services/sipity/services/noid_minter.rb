module Sipity
  module Services
    # This module uses noid client to mint a pid
    module NoidMinter
      def self.call(configuration = {})
        mint_a_pid(configuration: configuration)
      end

      def mint_a_pid(configuration)
        @server = configuration.fetch(:server) { Figaro.env.noid_server! }
        @port = configuration.fetch(:port) { Figaro.env.noid_port! }
        @pool = configuration.fetch(:pool) { Figaro.env.noid_pool! }
        connection.mint.first
      end

      def connection
        return @connection if @connection.present?
        @connection = ::NoidsClient::Connection.new("#{@server}:#{@port}").get_pool(@pool)
      end

      module_function :mint_a_pid
      private_class_method :mint_a_pid
      private :mint_a_pid

      module_function :connection
      private_class_method :connection
      private :connection
    end
  end
end
