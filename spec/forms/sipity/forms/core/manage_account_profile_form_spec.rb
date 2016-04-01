require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/core/manage_account_profile_form'

module Sipity
  module Forms
    module Core
      RSpec.describe ManageAccountProfileForm do
        let(:user) { User.new(id: 1) }
        let(:repository) { CommandRepositoryInterface.new }
        let(:attributes) { { agreed_to_terms_of_service: '1', preferred_name: 'Billy Joe Armstrong' } }
        subject { described_class.new(requested_by: user, repository: repository, attributes: attributes) }

        its(:default_repository) { is_expected.to respond_to(:user_agreed_to_terms_of_service) }

        context 'validations' do
          context 'with invalid data' do
            let(:attributes) { { agreed_to_terms_of_service: '0', preferred_name: '' } }
            it 'will require a preferred name' do
              subject.valid?
              expect(subject.errors[:preferred_name]).to_not be_blank
            end
            it 'will require agreement to the application\'s terms of service' do
              subject.valid?
              expect(subject.errors[:agreed_to_terms_of_service]).to_not be_blank
            end
          end
        end

        context 'submission with valid data' do
          it 'will update the user\'s preferred_name' do
            expect(repository).to receive(:update_user_preferred_name).and_call_original
            subject.submit
          end
          it 'will mark the user as having agreed to the terms of service' do
            expect(repository).to receive(:user_agreed_to_terms_of_service).and_call_original
            subject.submit
          end
          it 'will log the agreement event' do
            expect(repository).to receive(:log_event!).and_call_original
            subject.submit
          end
        end
      end
    end
  end
end
