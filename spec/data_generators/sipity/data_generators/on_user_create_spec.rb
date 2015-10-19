require 'rails_helper'
require 'sipity/data_generators/on_user_create'

module Sipity
  module DataGenerators
    RSpec.describe OnUserCreate do
      let(:user) { double('User') }

      context '.call' do
        it 'will instantiate then call the instance' do
          expect(described_class).to receive(:new).and_return(double(call: true))
          described_class.call(user: user)
        end
      end

      context 'add new user to all_registered user group' do
        let(:user) { Sipity::Factories.create_user }
        let(:all_verified_netid_users_group) { Sipity::Models::Group.find_by(name: Models::Group::ALL_VERIFIED_NETID_USERS) }
        it 'user will be part of all_registered user group' do
          described_class.call(user)
          expect(all_verified_netid_users_group.group_memberships.where(user: user).count).to eq(1)
        end
      end

    end
  end
end
