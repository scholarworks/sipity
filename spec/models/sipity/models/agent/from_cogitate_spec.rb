require 'spec_helper'

module Sipity
  module Models
    module Agent
      RSpec.describe FromCogitate do
        let(:agent) do
          Cogitate::Models::Agent.build_with_identifying_information(strategy: 'netid', identifying_value: 'hworld') do |the_agent|
            the_agent.add_email('hworld@nd.edu')
          end
        end
        let(:repository) { QueryRepositoryInterface.new }
        subject { described_class.new(cogitate_agent: agent, repository: repository) }
        it 'will honor the AgentInterface' do
          expect(Contract.valid?(subject, Sipity::Interfaces::AgentInterface)).to eq(true)
        end
        its(:email) { should eq('hworld@nd.edu') }
        its(:default_ids_decoder) { should respond_to(:call) }
        it { should delegate_method(:ids).to(:cogitate_agent) }
        it { should delegate_method(:name).to(:cogitate_agent) }
        its(:user_signed_in?) { should eq(true) }
        its(:netid) { should eq('hworld') }
        context '#agreed_to_application_terms_of_service?' do
          it 'will use the given repository and identifier' do
            expect(repository).to receive(
              :agreed_to_application_terms_of_service?
            ).with(identifier_id: agent.id).and_return(true)
            expect(subject.agreed_to_application_terms_of_service?).to eq(true)
          end
        end
      end
    end
  end
end
