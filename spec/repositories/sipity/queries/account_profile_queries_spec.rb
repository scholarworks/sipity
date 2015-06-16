require 'rails_helper'

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
    end
  end
end
