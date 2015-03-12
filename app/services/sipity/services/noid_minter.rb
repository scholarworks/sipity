module Sipity
  module Services
    # This class uses noid client to mint a pid
    class NoidMinter
      def self.call(configuration = {})
        new(configuration: configuration).call
      end

      def initialize(configuration)
        @server = configuration.fetch(:server) { default_server }
        @port = configuration.fetch(:port) { default_port }
        @pool = configuration.fetch(:pool) { default_pool }
      end

      attr_reader :connection

      def connection
        @connection = ::NoidsClient::Connection.new("#{@server}:#{@port}").get_pool(@pool)
      end

      # Returns a single NOID
      def call
        connection.mint.first
      end

      private

      def default_server
        Rails.application.secrets.noid_server
      end

      def default_port
        Rails.application.secrets.noid_port
      end

      def default_pool
        Rails.application.secrets.noid_pool
      end
    end
  end
end
