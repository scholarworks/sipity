require 'rails_helper'

module Sipity
  module Commands
    RSpec.describe DoiCommands, type: :isolated_command_module do
      context '#update_work_doi_creation_request_state!' do
        let(:work) { Models::Work.new(id: 123) }
        let!(:doi_creation_request) { Models::DoiCreationRequest.create!(work: work) }
        context 'given a valid state' do
          let(:state) { 'request_completed' }
          it 'will update the state' do
            expect { test_repository.update_work_doi_creation_request_state!(work: work, state: state) }.
              to change { doi_creation_request.reload.state }.to(state)
          end
        end

        context 'given an invalid state' do
          let(:state) { 'not_valid_even_once' }
          it 'will raise an ArgumentError' do
            expect { test_repository.update_work_doi_creation_request_state!(work: work, state: state) }.
              to raise_error(ArgumentError)
          end
        end
      end

      context '#submit_assign_a_doi_form' do
        let(:work) { Models::Work.new(id: '1234') }
        let(:user) { User.new(id: '123') }
        let(:attributes) { { work: work, identifier: identifier } }
        let(:form) { test_repository.build_assign_a_doi_form(attributes) }

        context 'on invalid data' do
          let(:identifier) { '' }
          it 'returns false and does not assign a DOI' do
            expect(test_repository.submit_assign_a_doi_form(form, requested_by: user)).to eq(false)
          end
        end
        context 'on valid data' do
          let(:identifier) { 'doi:abc' }
          it 'will return true after assigning the DOI to the work and logging the event' do
            response = test_repository.submit_assign_a_doi_form(form, requested_by: user)
            expect(response).to be_truthy
            expect(test_repository.doi_already_assigned?(work)).to be_truthy
            expect(Models::EventLog.where(user: user, event_name: 'submit_assign_a_doi_form').count).to eq(1)
          end
        end
      end

      context '#submit_request_a_doi_form' do
        let(:user) { User.new(id: 12) }
        let(:work) { Models::Work.new(id: '1234') }
        let(:attributes) do
          { work: work, publisher: publisher, publication_date: '2014-10-11', authors: ['Frog', 'Toad'] }
        end
        let(:form) { test_repository.build_request_a_doi_form(attributes) }

        context 'on invalid data' do
          let(:publisher) { '' }
          it 'will return false and does not create the DOI request' do
            expect(test_repository.submit_request_a_doi_form(form, requested_by: user)).to eq(false)
          end
        end

        context 'on valid data' do
          let(:publisher) { 'Valid Publisher' }
          it 'will return true having created the DOI request, appended the captured attributes, and loggged the event' do
            expect(Jobs).to receive(:submit).with('doi_creation_request_job', kind_of(Fixnum))
            response = test_repository.submit_request_a_doi_form(form, requested_by: user)

            expect(response).to be_truthy
            expect(test_repository.doi_request_is_pending?(work)).to be_truthy
            expect(work.additional_attributes.count).to eq(2)
            expect(Models::EventLog.where(user: user, event_name: 'submit_request_a_doi_form').count).to eq(1)
          end
        end
      end

      context '#update_work_with_doi_predicate!' do
        let(:work) { Models::Work.new(id: 1) }
        let(:value) { 'doi:oh-my' }
        it 'will update the underlying doi predicates' do
          test_repository.update_work_with_doi_predicate!(work: work, values: value)
        end
      end
    end
  end
end
