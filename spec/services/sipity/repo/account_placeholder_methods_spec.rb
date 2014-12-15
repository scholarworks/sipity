require 'rails_helper'

module Sipity
  module Repo
    RSpec.describe AccountPlaceholderMethods, type: :repository do
      context '#build_create_orcid_account_placeholder_form' do
        subject { test_repository.build_create_orcid_account_placeholder_form }
        it { should respond_to :identifier }
        it { should respond_to :name }
      end
      context '#submit_create_orcid_account_placeholder_form' do
        let(:user) { User.new(id: 1) }
        let(:form) { test_repository.build_create_orcid_account_placeholder_form(attributes: { identifier: '0000-0002-8205-121X' }) }
        context 'with invalid data' do
          it 'will return false' do
            allow(form).to receive(:valid?).and_return(false)
            expect(test_repository.submit_create_orcid_account_placeholder_form(form, requested_by: user)).to be_falsey
          end
        end
        context 'with valid data' do
          it 'will return the persisted account placeholder'
          it 'will record an event in the event log'
          it 'will create a permission entry for the requesting user'
          it 'will persist an account placeholder entity'
        end
      end
    end
  end
end
