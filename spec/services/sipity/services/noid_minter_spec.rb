require 'rails_helper'
require 'sipity/services/noid_minter'
module Sipity
  module Services
    describe NoidMinter do
      include ::Sipity::Services::NoidMinter
      let(:pid) { "pid" }
      let(:connection) { double(mint: [pid]) }

      context '#call' do
        it 'will mint a pid' do
          expect(described_class).to receive(:connection).
            and_return(connection)
          expect(described_class.call).to eq(pid)
        end
      end

      context '#connections' do
        let(:first_connection) { described_class.connection }
        it 'verify connections are cached' do
          expect(::NoidsClient::Connection).to receive_message_chain(:new, :get_pool).
            and_return(connection)
          next_connection = described_class.connection
          expect(first_connection.object_id).to eq(next_connection.object_id)
        end
      end
    end
  end
end
