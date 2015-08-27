require 'rails_helper'
require 'sipity/queries/account_profile_queries'

module Sipity
  module Queries
    RSpec.describe AccountProfileQueries, type: :isolated_repository_module do
      context '#build_account_profile_form' do
        subject { test_repository.build_account_profile_form(requested_by: user, attributes: attributes) }
        let(:user) { double(name: 'Hello') }
        let(:attributes) { { 'test' => 'test' } }
        it { should respond_to :preferred_name }
        it { should respond_to :agreed_to_terms_of_service }
      end

      context '#agreed_to_application_terms_of_service?' do
        it 'will execute valid SQL' do
          expect(test_repository.agreed_to_application_terms_of_service?(identifier_id: '123')).to eq(false)
        end
      end
    end
  end
end
