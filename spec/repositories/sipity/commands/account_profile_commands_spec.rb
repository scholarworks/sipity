require 'spec_helper'
require 'sipity/commands/account_profile_commands'

module Sipity
  module Commands
    RSpec.describe AccountProfileCommands, type: :isolated_repository_module do
      context '#user_agreed_to_terms_of_service' do
        let(:user) { Models::IdentifiableAgent.new_from_netid(netid: 'hworld') }
        it 'register the AgreedToTermsOfService but only once' do
          expect do
            test_repository.user_agreed_to_terms_of_service(user: user)
            test_repository.user_agreed_to_terms_of_service(user: user)
          end.to change { Models::AgreedToTermsOfService.count }.by(1)
        end
      end
    end
  end
end
