require 'rails_helper'

module Sipity
  module Commands
    RSpec.describe CitationCommands, type: :command_repository do

      context '#submit_assign_a_citation_form' do
        let(:work) { Models::Work.new(id: '1234') }
        let(:attributes) { { work: work, citation: citation, type: '1234' } }
        let(:form) { test_repository.build_assign_a_citation_form(attributes) }
        let(:user) { User.new(id: 3) }

        context 'on invalid data' do
          let(:citation) { '' }
          it 'returns false and does not assign a Citation' do
            expect(test_repository.submit_assign_a_citation_form(form, requested_by: user)).to eq(false)
          end
        end

        context 'on valid data' do
          let(:citation) { 'citation:abc' }
          it 'will assign the Citation to the work and create an event' do
            response = test_repository.submit_assign_a_citation_form(form, requested_by: user)
            expect(response).to be_truthy
            expect(test_repository.citation_already_assigned?(work)).to be_truthy
            expect(work.additional_attributes.count).to eq(2)
            expect(Models::EventLog.where(user: user, event_name: 'assign_a_citation_form/submit').count).to eq(1)
          end
        end
      end
    end
  end
end
