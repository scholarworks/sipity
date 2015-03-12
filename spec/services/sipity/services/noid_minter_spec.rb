require 'spec_helper'
module Sipity
  module Services
    RSpec.describe NoidMinter do
      let(:pid) { "pid" }
      let(:connection) { double }
      let(:configuration) do
        { server: 'noid.example.com', port: '13001', pool: "pool_name" }
      end
      subject { described_class.new(configuration) }

      it 'exposes .call as a convenience method' do
        expect_any_instance_of(described_class).to receive(:call)
        described_class.call(configuration)
      end

      context 'connection' do
        it 'should get a connection from noid server' do
          allow(::NoidsClient::Connection).to receive_message_chain(:new, :get_pool).
            and_return(connection)
          expect(subject.connection).to eq(connection)
        end
      end

      context "#call" do
        subject { described_class.new(configuration) }
        let(:pid) { 'a pid' }
        context 'with valid options' do
          it "will return a pid minted by noid server" do
            expect(subject).to receive(:connection).and_return(connection)
            expect(connection).to receive(:mint).and_return([pid])
            expect(subject.call).to eq(pid)
          end
        end
      end
    end
  end
end
