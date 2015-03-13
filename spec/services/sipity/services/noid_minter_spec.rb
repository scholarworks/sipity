require 'spec_helper'
module Sipity
  module Services
    describe NoidMinter do
      include ::Sipity::Services::NoidMinter
      let(:pid) { "pid" }
      let(:connection) { double }
      let(:configuration) do
        { server: 'noid.example.com', port: '13001', pool: "pool_name" }
      end

      context '.call' do
        it 'will call the underlying mint_a_pid method' do
          expect(described_class).to receive(:mint_a_pid).and_return(pid)
          expect(described_class.call(configuration)).to eq(pid)
        end
      end

      context '#mint_a_pid' do
        it 'will be a private instance method' do
          expect(self.class.private_instance_methods).to include(:mint_a_pid)
        end

        it 'will mint a pid' do
          expect(::NoidsClient::Connection).to receive_message_chain(:new, :get_pool).
            and_return(connection)
          expect(connection).to receive(:mint).and_return([pid])
          expect(described_class.call(configuration)).to eq(pid)

        end
      end
    end
  end
end
