require 'rails_helper'

module Sipity
  module Repo
    RSpec.describe HeaderMethods, type: :repository do
      let!(:repository_class) do
        class TestRepository
          include HeaderMethods
        end
      end
      subject { repository_class.new }
      after { Sipity::Repo.send(:remove_const, :TestRepository) }

      it 'will have a permanent URL for a given header' do
        expect(subject.permanent_uri_for_header_id(123)).to be_a(URI)
      end

      context '#find_headers_for' do
        let(:user_one) { User.new(id: 1) }
        let(:user_two) { User.new(id: 2) }
        let(:form) { subject.build_create_header_form(attributes: { title: 'My Title', work_publication_strategy: 'do_not_know' }) }
        let!(:header_one) { subject.submit_create_header_form(form, requested_by: user_one) }
        let!(:header_two) { subject.submit_create_header_form(form, requested_by: user_two) }
        it 'will include headers that were created by the user' do
          expect(subject.find_headers_for(user: user_one)).to eq([header_one])
        end
      end

      context '#assign_a_pid' do
        it 'will assign a unique permanent persisted identifier for the header'
      end

      context '#find_header' do
        it 'raises an exception if nothing is found' do
          expect { subject.find_header('8675309') }.to raise_error
        end
        it 'returns the Header when the object is found' do
          allow(Models::Header).to receive(:find).with('8675309').and_return(:found)
          expect(subject.find_header('8675309')).to eq(:found)
        end
      end

      context '#submit_create_header_form' do
        let(:user) { User.new(id: '123') }
        let(:form) do
          subject.build_create_header_form(
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
            expect { subject.submit_create_header_form(form, requested_by: user) }.
              to_not change { Models::Header.count }
          end
          it 'will return false' do
            allow(form).to receive(:valid?).and_return(false)
            expect(subject.submit_create_header_form(form, requested_by: user)).to eq(false)
          end
        end
        context 'with valid data' do
          let(:user) { User.new(id: '123') }
          it 'will return the header having created the header, added the attributes,
              assigned collaborators, assigned permission, and loggged the event' do
            allow(form).to receive(:valid?).and_return(true)
            response = subject.submit_create_header_form(form, requested_by: user)

            expect(response).to be_a(Models::Header)
            expect(Models::Header.count).to eq(1)
            expect(response.additional_attributes.count).to eq(1)
            expect(Models::Collaborator.count).to eq(1)
            expect(Models::Permission.where(user: user, role: Models::Permission::CREATING_USER).count).to eq(1)
            expect(Models::EventLog.where(user: user, event_name: 'submit_create_header_form').count).to eq(1)
          end
        end
      end

      context '#build_create_header_form' do
        it 'will build an object that can be submitted' do
          expect(subject.build_create_header_form).to respond_to(:submit)
        end
      end

      context '#build_update_header_form' do
        let(:header) { Models::Header.new(title: 'Hello World', id: '123') }
        it 'will raise an exception if the header is not persisted' do
          allow(header).to receive(:persisted?).and_return(false)
          expect { subject.build_update_header_form(header: header) }.
            to raise_error(RuntimeError)
        end
        context 'with a persisted object will return an object that' do
          before { allow(header).to receive(:persisted?).and_return(true) }
          subject { repository_class.new.build_update_header_form(header: header) }
          it { should respond_to :submit }
          it 'will expose an attribute of the underlying header' do
            expect(subject.title).to eq(header.title)
          end
          it 'will expose an additional attribute' do
            Models::AdditionalAttribute.create!(header: header, key: 'publisher', value: 'parmasean')
            expect(subject.publisher).to eq('parmasean')
          end
        end
      end

      context '#submit_update_header_form' do
        let(:user) { User.new(id: '123') }
        let(:header) { Models::Header.create(title: 'My Title', work_publication_strategy: 'do_not_know') }
        let(:form) { subject.build_update_header_form(header: header, attributes: { title: 'My New Title', publisher: 'dance' }) }
        context 'with invalid data' do
          before do
            allow(header).to receive(:persisted?).and_return(true)
            allow(form).to receive(:valid?).and_return(false)
          end
          it 'will return false' do
            expect(subject.submit_update_header_form(form, requested_by: user)).to eq(false)
          end
          it 'will NOT update the header' do
            expect { subject.submit_update_header_form(form, requested_by: user) }.
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
            response = subject.submit_update_header_form(form, requested_by: user)

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
