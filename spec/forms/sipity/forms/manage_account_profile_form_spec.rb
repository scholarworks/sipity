require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe ManageAccountProfileForm  do
      let(:user) { User.new(id: 1) }
      let(:repository) { CommandRepositoryInterface.new }
      let(:attributes) { { agreed_to_terms_of_service: '1', preferred_name: 'Billy Joe Armstrong' } }
      subject { described_class.new(user: user, repository: repository, attributes: attributes) }

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
          expect(repository).to receive(:update_user_preferred_name).with(user: user, preferred_name: attributes.fetch(:preferred_name))
          subject.submit(requested_by: user)
        end
        it 'will record the user\'s agreement to the terms of service' do
          expect(repository).to receive(:log_event!).with(entity: user, user: user, event_name: described_class::EVENT_NAME)
          subject.submit(requested_by: user)
        end
      end
    end
  end
end
