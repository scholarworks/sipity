require 'rails_helper'

module Sip
  module Repo
    RSpec.describe DoiMethods, type: :repository do
      let!(:klass) do
        class TestRepository
          include DoiMethods
        end
      end
      subject { klass.new }
      after { Sip::Repo.send(:remove_const, :TestRepository) }

      context '#submit_assign_a_doi_form' do
        let(:header) { FactoryGirl.build_stubbed(:sip_header, id: '1234') }
        let(:attributes) { { header: header, identifier: identifier } }
        let(:form) { subject.build_assign_a_doi_form(attributes) }

        context 'on invalid data' do
          let(:identifier) { '' }
          it 'returns false and does not assign a DOI' do
            expect(subject.submit_assign_a_doi_form(form)).to eq(false)
          end
        end
        context 'on valid data' do
          let(:identifier) { 'doi:abc' }
          it 'will assign the DOI to the header' do
            expect { subject.submit_assign_a_doi_form(form) }.
              to change { subject.doi_already_assigned?(header) }.
              from(false).to(true)
          end
          it 'will return true' do
            expect(subject.submit_assign_a_doi_form(form)).to be_truthy
          end
          it 'will create an event log entry for the requesting user' do
            user = User.new(id: '123')
            expect { subject.submit_assign_a_doi_form(form, requested_by: user) }.
              to change { EventLog.where(user: user, event_name: 'submit_assign_a_doi_form').count }.by(1)
          end
        end
      end

      context '#submit_request_a_doi_form' do
        let(:header) { FactoryGirl.build_stubbed(:sip_header, id: '1234') }
        let(:attributes) do
          { header: header, publisher: publisher, publication_date: '2014-10-11', authors: ['Frog', 'Toad'] }
        end
        let(:form) { subject.build_request_a_doi_form(attributes) }

        context 'on invalid data' do
          let(:publisher) { '' }
          it 'will return false and does not create the DOI request' do
            expect(subject.submit_request_a_doi_form(form)).to eq(false)
          end
        end

        context 'on valid data' do
          let(:publisher) { 'Valid Publisher' }
          it 'will return true' do
            expect(subject.submit_request_a_doi_form(form)).to be_truthy
          end
          it 'will create the DOI request and append the captured attributes' do
            expect { subject.submit_request_a_doi_form(form) }.to(
              change { subject.doi_request_is_pending?(header) }.from(false).to(true) &&
              change { header.additional_attributes.count }.by(2)
            )
          end
          it 'will create an event log entry for the requesting user' do
            user = User.new(id: '123')
            expect { subject.submit_request_a_doi_form(form, requested_by: user) }.
              to change { EventLog.where(user: user, event_name: 'submit_request_a_doi_form').count }.by(1)
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

      it { should respond_to :doi_request_is_pending? }
      it { should respond_to :doi_already_assigned? }
    end
  end
end
