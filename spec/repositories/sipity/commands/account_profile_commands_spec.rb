require 'spec_helper'

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
    end
  end
end