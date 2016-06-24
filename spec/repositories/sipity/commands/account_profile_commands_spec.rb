require "rails_helper"
require 'sipity/commands/account_profile_commands'

module Sipity
  module Commands
    RSpec.describe AccountProfileCommands, type: :isolated_repository_module do
      context '#update_user_preferred_name' do
        let(:user) { User.new(id: 1) }
        let(:name) { 'Jean-Ralphio' }
        it 'will update the given user\'s name' do
          expect(user).to receive(:update).with(name: name)
          test_repository.update_user_preferred_name(user: user, preferred_name: name)
        end
      end
      context '#user_agreed_to_terms_of_service' do
        let(:user) { User.new(id: 1) }
        it 'will update the given user\'s name' do
          expect(user).to receive(:update).with(agreed_to_terms_of_service: true)
          test_repository.user_agreed_to_terms_of_service(user: user)
        end
      end
    end
  end
end
