require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/core/manage_account_profile_form'

module Sipity
  module Forms
    module Core
      RSpec.describe ManageAccountProfileForm do
        let(:user) { Models::IdentifiableAgent.new_from_netid(netid: 'hworld') }
        let(:repository) { CommandRepositoryInterface.new }
        let(:attributes) { { agreed_to_terms_of_service: '1' } }
        subject { described_class.new(requested_by: user, repository: repository, attributes: attributes) }

        its(:default_repository) { should respond_to(:user_agreed_to_terms_of_service) }

        context 'validations' do
          context 'with invalid data' do
            let(:attributes) { { agreed_to_terms_of_service: '0' } }
            it 'will require agreement to the application\'s terms of service' do
              subject.valid?
              expect(subject.errors[:agreed_to_terms_of_service]).to_not be_blank
            end
          end
        end

        context 'submission with valid data' do
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
