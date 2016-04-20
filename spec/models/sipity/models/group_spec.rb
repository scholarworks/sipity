require 'rails_helper'
require 'sipity/models/group'

module Sipity
  module Models
    RSpec.describe Group, type: :model do
      subject { described_class.new }
      its(:valid?) { is_expected.to be false }

      it { is_expected.to delegate_method(:to_s).to(:name) }

      it { is_expected.to have_many(:event_logs) }

      it 'will have a Group.all_registered_users' do
        expect(described_class.all_registered_users).to be_persisted
      end

      context '.basic_authorization_string_for!' do
        it 'will raise InvalidAuthorizationCredentialsError when the group is not found' do
          expect { described_class.basic_authorization_string_for!(name: 'ketchup') }.to(
            raise_error(Exceptions::InvalidAuthorizationCredentialsError)
          )
        end
        it 'will raise InvalidAuthorizationCredentialsError when the group does not have an api key' do
          Models::Group.create!(name: 'ketchup')
          expect { described_class.basic_authorization_string_for!(name: 'ketchup') }.to(
            raise_error(Exceptions::InvalidAuthorizationCredentialsError)
          )
        end
        it 'will return a valid Basic Authentication string if an api_key exists' do
          Models::Group.create!(name: 'ketchup', api_key: '1234')
          expect(described_class.basic_authorization_string_for!(name: 'ketchup')).to eq('ketchup:1234')
        end
      end
    end
  end
end
