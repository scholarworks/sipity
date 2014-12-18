require 'spec_helper'

module Sipity
  module Queries
    RSpec.describe NotificationQueries, type: :repository_methods do
      context '#emails_for_associated_users' do
        let(:entity) { Models::Header.create! }
        let(:associated_user) { Sipity::Factories.create_user(email: 'associated@hotmail.com') }
        let(:associated_by_group_user) { Sipity::Factories.create_user(email: 'group_associated@hotmail.com') }
        let(:not_associated_user) { Sipity::Factories.create_user(email: 'not_associated@hotmail.com') }
        let(:user_with_wrong_role) { Sipity::Factories.create_user(email: 'wrong_role@hotmail.com') }
        let(:associated_group) { Models::Group.create!(name: 'associated') }
        let(:role) { 'arbitrary' }
        let(:wrong_role) { 'wrong_role' }

        before do
          # REVIEW: Should I be using Repository services?
          Models::GroupMembership.create!(group: associated_group, user: associated_by_group_user)

          Models::Permission.create!(actor: user_with_wrong_role, role: wrong_role, entity: entity)
          Models::Permission.create!(actor: associated_group, role: role, entity: entity)
          Models::Permission.create!(actor: associated_user, role: role, entity: entity)
        end

        it 'will return emails from users directly associated with the entity' do
          results = test_repository.emails_for_associated_users(roles: role, entity: entity)
          expect(results.sort).to eq(['associated@hotmail.com', 'group_associated@hotmail.com'])
        end
      end
    end
  end
end
