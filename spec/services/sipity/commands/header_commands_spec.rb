require 'rails_helper'

module Sipity
  module Commands
    RSpec.describe HeaderCommands, type: :repository_methods do
      context '#find_headers_for' do
        let(:user_one) { User.new(id: 1) }
        let(:user_two) { User.new(id: 2) }
        let(:form) { test_repository.build_create_header_form(attributes: { title: 'My Title', work_publication_strategy: 'do_not_know' }) }
        let!(:header_one) { test_repository.submit_create_header_form(form, requested_by: user_one) }
        let!(:header_two) { test_repository.submit_create_header_form(form, requested_by: user_two) }
        it 'will include headers that were created by the user' do
          expect(test_repository.find_headers_for(user: user_one)).to eq([header_one])
        end
      end

      context '#assign_a_pid' do
        it 'will assign a unique permanent persisted identifier for the header'
      end

      context '#update_processing_state!' do
        let(:header) { Models::Header.create! }
        it 'will update the underlying state of the object' do
          expect { test_repository.update_processing_state!(header: header, new_processing_state: 'hello') }.
            to change { header.processing_state }.to('hello')
        end
      end

      context '#submit_create_header_form' do
        let(:user) { User.new(id: '123') }
        let(:form) do
          test_repository.build_create_header_form(
            attributes: {
              title: 'This is my title',
              work_publication_strategy: 'do_not_know',
              publication_date: '2014-11-12',
              collaborators_attributes: {
                "0" => { name: "The person", role: Models::Collaborator::DEFAULT_ROLE }
              }
            }
          )
        end
        context 'with invalid data' do
          it 'will not create a a header' do
            allow(form).to receive(:valid?).and_return(false)
            expect { test_repository.submit_create_header_form(form, requested_by: user) }.
              to_not change { Models::Header.count }
          end
          it 'will return false' do
            allow(form).to receive(:valid?).and_return(false)
            expect(test_repository.submit_create_header_form(form, requested_by: user)).to eq(false)
          end
        end
        context 'with valid data' do
          let(:user) { User.new(id: '123') }
          it 'will return the header having created the header, added the attributes,
              assigned collaborators, assigned permission, and loggged the event' do
            allow(form).to receive(:valid?).and_return(true)
            response = test_repository.submit_create_header_form(form, requested_by: user)

            expect(response).to be_a(Models::Header)
            expect(Models::Header.count).to eq(1)
            expect(response.additional_attributes.count).to eq(1)
            expect(Models::Collaborator.count).to eq(1)
            expect(Models::Permission.where(user: user, role: Models::Permission::CREATING_USER).count).to eq(1)
            expect(Models::EventLog.where(user: user, event_name: 'submit_create_header_form').count).to eq(1)
          end
        end
      end

      context '#submit_update_header_form' do
        let(:user) { User.new(id: '123') }
        let(:header) { Models::Header.create(title: 'My Title', work_publication_strategy: 'do_not_know') }
        let(:form) { test_repository.build_update_header_form(header: header, attributes: { title: 'My New Title', publisher: 'dance' }) }
        context 'with invalid data' do
          before do
            allow(header).to receive(:persisted?).and_return(true)
            allow(form).to receive(:valid?).and_return(false)
          end
          it 'will return false' do
            expect(test_repository.submit_update_header_form(form, requested_by: user)).to eq(false)
          end
          it 'will NOT update the header' do
            expect { test_repository.submit_update_header_form(form, requested_by: user) }.
              to_not change { header.reload.title }
          end
        end
        context 'with valid data' do
          before do
            Models::AdditionalAttribute.create!(header: header, key: 'publisher', value: 'parmasean')
            allow(header).to receive(:persisted?).and_return(true)
            allow(form).to receive(:valid?).and_return(true)
          end
          it 'will return the header after updating the header, additional attributes, and creating an event log entry' do
            response = test_repository.submit_update_header_form(form, requested_by: user)

            expect(response).to eq(header)
            expect(header.reload.title).to eq('My New Title')
            expect(Models::AdditionalAttribute.where(header: header).pluck(:key, :value)).to eq([['publisher', 'dance']])
            expect(Models::EventLog.where(user: user, event_name: 'submit_update_header_form').count).to eq(1)
          end
        end
      end
    end
  end
end
