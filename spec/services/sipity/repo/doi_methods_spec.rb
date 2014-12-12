require 'rails_helper'

module Sipity
  module Repo
    RSpec.describe DoiMethods, type: :repository do
      let!(:klass) do
        class TestRepository
          include DoiMethods
        end
      end
      subject { klass.new }
      after { Sipity::Repo.send(:remove_const, :TestRepository) }

      context '#find_doi_creation_request' do
        it 'will find based on the given header'
        it 'will raise an exception if one cannot be found'
      end

      context 'find_doi_creation_request_by_id' do
        it 'will find based on the id' do
          header = Models::Header.new(id: 123)
          entity = Models::DoiCreationRequest.create!(header: header)
          expect(subject.find_doi_creation_request_by_id(entity.id)).to eq(entity)
        end
        it 'will raise an exception if one cannot be found' do
          expect { subject.find_doi_creation_request_by_id(1) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context '#submit_assign_a_doi_form' do
        let(:header) { FactoryGirl.build_stubbed(:sipity_header, id: '1234') }
        let(:user) { User.new(id: '123') }
        let(:attributes) { { header: header, identifier: identifier } }
        let(:form) { subject.build_assign_a_doi_form(attributes) }

        context 'on invalid data' do
          let(:identifier) { '' }
          it 'returns false and does not assign a DOI' do
            expect(subject.submit_assign_a_doi_form(form, requested_by: user)).to eq(false)
          end
        end
        context 'on valid data' do
          let(:identifier) { 'doi:abc' }
          it 'will assign the DOI to the header and log the event' do
            expect { subject.submit_assign_a_doi_form(form, requested_by: user) }.to(
              change { subject.doi_already_assigned?(header) }.from(false).to(true) &&
              change { Models::EventLog.where(user: user, event_name: 'submit_assign_a_doi_form').count }.by(1)
            )
          end
          it 'will return true' do
            expect(subject.submit_assign_a_doi_form(form, requested_by: user)).to be_truthy
          end
        end
      end

      context '#gather_doi_creation_request_metadata' do
        it 'will delegate to the gather' do
          header = double
          expect(Services::DoiCreationRequestMetadataGatherer).to receive(:call).with(header: header)
          subject.gather_doi_creation_request_metadata(header: header)
        end
      end

      context '#submit_request_a_doi_form' do
        let(:user) { User.new(id: 12) }
        let(:header) { FactoryGirl.build_stubbed(:sipity_header, id: '1234') }
        let(:attributes) do
          { header: header, publisher: publisher, publication_date: '2014-10-11', authors: ['Frog', 'Toad'] }
        end
        let(:form) { subject.build_request_a_doi_form(attributes) }

        context 'on invalid data' do
          let(:publisher) { '' }
          it 'will return false and does not create the DOI request' do
            expect(subject.submit_request_a_doi_form(form, requested_by: user)).to eq(false)
          end
        end

        context 'on valid data' do
          let(:publisher) { 'Valid Publisher' }
          it 'will return true' do
            expect(Jobs).to receive(:submit).with('doi_creation_request_job', kind_of(Fixnum))
            expect(subject.submit_request_a_doi_form(form, requested_by: user)).to be_truthy
          end
          it 'will create the DOI request and append the captured attributes and log the event' do
            expect(Jobs).to receive(:submit).with('doi_creation_request_job', kind_of(Fixnum))
            expect { subject.submit_request_a_doi_form(form, requested_by: user) }.to(
              change { subject.doi_request_is_pending?(header) }.from(false).to(true) &&
              change { header.additional_attributes.count }.by(2) &&
              change { Models::EventLog.where(user: user, event_name: 'submit_request_a_doi_form').count }.by(1)
            )
          end
        end
      end

      context '#build_assign_a_doi_form object' do
        let(:header) { double }
        subject { klass.new.build_assign_a_doi_form(header: header) }
        it { should respond_to :header }
        it { should respond_to :identifier }
        it { should respond_to :identifier_key }
        it { should respond_to :submit }
      end

      context '#build_request_a_doi_form object' do
        let(:header) { double }
        subject { klass.new.build_request_a_doi_form(header: header) }
        it { should respond_to :title }
        it { should respond_to :authors }
        it { should respond_to :publication_date }
        it { should respond_to :publisher }
        it { should respond_to :submit }
      end

      context '#doi_request_is_pending?' do
        let(:header) { Models::Header.new(id: 1) }
        it 'will see if a DOI Creation Request exists' do
          expect(klass.new.doi_request_is_pending?(header)).to be_falsey
        end
      end

      context '#doi_already_assigned?' do
        let(:header) { Models::Header.new(id: 1) }
        it 'will see if a DOI has been assigned to the header' do
          expect(klass.new.doi_already_assigned?(header)).to be_falsey
        end
      end
    end
  end
end
