require 'rails_helper'

module Sipity
  module Commands
    RSpec.describe SipCommands, type: :repository_methods do
      context '#assign_a_pid' do
        it 'will assign a unique permanent persisted identifier for the work'
      end

      context '#update_processing_state!' do
        let(:work) { Models::Sip.create! }
        it 'will update the underlying state of the object' do
          expect { test_repository.update_processing_state!(work: work, new_processing_state: 'hello') }.
            to change { work.processing_state }.to('hello')
        end
      end

      context '#submit_create_work_form' do
        let(:user) { User.new(id: '123') }
        let(:form) do
          test_repository.build_create_work_form(
            attributes: {
              title: 'This is my title',
              work_publication_strategy: 'do_not_know',
              publication_date: '2014-11-12',
              access_rights_answer: Models::TransientAnswer::ACCESS_RIGHTS_PRIVATE
            }
          )
        end
        context 'with invalid data' do
          it 'will not create a a work' do
            allow(form).to receive(:valid?).and_return(false)
            expect { test_repository.submit_create_work_form(form, requested_by: user) }.
              to_not change { Models::Sip.count }
          end
          it 'will return false' do
            allow(form).to receive(:valid?).and_return(false)
            expect(test_repository.submit_create_work_form(form, requested_by: user)).to eq(false)
          end
        end
        context 'with valid data' do
          let(:user) { User.new(id: '123') }
          it 'will return the work having created the work, added the attributes,
              assigned collaborators, assigned permission, and loggged the event' do
            allow(form).to receive(:valid?).and_return(true)
            response = test_repository.submit_create_work_form(form, requested_by: user)

            expect(response).to be_a(Models::Sip)
            expect(Models::Sip.count).to eq(1)
            expect(Models::TransientAnswer.count).to eq(1)
            expect(response.additional_attributes.count).to eq(1)
            expect(Models::Permission.where(actor: user, acting_as: Models::Permission::CREATING_USER).count).to eq(1)
            expect(Models::EventLog.where(user: user, event_name: 'submit_create_work_form').count).to eq(1)
          end
        end
      end

      context '#submit_update_work_form' do
        let(:user) { User.new(id: '123') }
        let(:work) { Models::Sip.create(title: 'My Title', work_publication_strategy: 'do_not_know') }
        let(:form) { test_repository.build_update_work_form(work: work, attributes: { title: 'My New Title', publisher: 'dance' }) }
        context 'with invalid data' do
          before do
            allow(work).to receive(:persisted?).and_return(true)
            allow(form).to receive(:valid?).and_return(false)
          end
          it 'will return false' do
            expect(test_repository.submit_update_work_form(form, requested_by: user)).to eq(false)
          end
          it 'will NOT update the work' do
            expect { test_repository.submit_update_work_form(form, requested_by: user) }.
              to_not change { work.reload.title }
          end
        end
        context 'with valid data' do
          before do
            Models::AdditionalAttribute.create!(work: work, key: 'publisher', value: 'parmasean')
            allow(work).to receive(:persisted?).and_return(true)
            allow(form).to receive(:valid?).and_return(true)
          end
          it 'will return the work after updating the work, additional attributes, and creating an event log entry' do
            response = test_repository.submit_update_work_form(form, requested_by: user)

            expect(response).to eq(work)
            expect(work.reload.title).to eq('My New Title')
            expect(Models::AdditionalAttribute.where(work: work).pluck(:key, :value)).to eq([['publisher', 'dance']])
            expect(Models::EventLog.where(user: user, event_name: 'submit_update_work_form').count).to eq(1)
          end
        end
      end
    end
  end
end
