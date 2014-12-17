require 'rails_helper'

module Sipity
  module RepositoryMethods
    RSpec.describe CitationMethods, type: :repository_methods do

      context '#submit_assign_a_citation_form' do
        let(:header) { Models::Header.new(id: '1234') }
        let(:attributes) { { header: header, citation: citation, type: '1234' } }
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
          it 'will assign the Citation to the header and create an event' do
            response = test_repository.submit_assign_a_citation_form(form, requested_by: user)
            expect(response).to be_truthy
            expect(test_repository.citation_already_assigned?(header)).to be_truthy
            expect(header.additional_attributes.count).to eq(2)
            expect(Models::EventLog.where(user: user, event_name: 'submit_assign_a_citation_form').count).to eq(1)
          end
        end
      end

      context '#build_assign_a_citation_form object' do
        let(:header) { double }
        subject { test_repository.build_assign_a_citation_form(header: header) }
        it { should respond_to :header }
        it { should respond_to :citation }
        it { should respond_to :type }
        it { should respond_to :submit }
      end

      context '#citation_already_assigned?' do
        it 'will query the header' do
          header = Models::Header.new(id: 1)
          expect(test_repository.citation_already_assigned?(header)).to eq(false)
        end
      end
    end
  end
end
