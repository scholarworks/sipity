require 'rails_helper'

module Sipity
  module Repo
    RSpec.describe CitationMethods, type: :repository do
      let!(:repository_class) do
        class TestRepository
          include CitationMethods
        end
      end
      subject { repository_class.new }
      after { Sipity::Repo.send(:remove_const, :TestRepository) }

      context '#submit_assign_a_citation_form' do
        let(:header) { FactoryGirl.build_stubbed(:sipity_header, id: '1234') }
        let(:attributes) { { header: header, citation: citation, type: '1234' } }
        let(:form) { Repository.new.build_assign_a_citation_form(attributes) }

        context 'on invalid data' do
          let(:citation) { '' }
          it 'returns false and does not assign a Citation' do
            expect(subject.submit_assign_a_citation_form(form)).to eq(false)
          end
        end

        context 'on valid data' do
          let(:citation) { 'citation:abc' }
          it 'will assign the Citation to the header' do
            expect { subject.submit_assign_a_citation_form(form) }.to(
              change { subject.citation_already_assigned?(header) }.from(false).to(true) &&
              change { header.additional_attributes.count }.by(2)
            )
          end
          it 'will return a truthy object' do
            expect(subject.submit_assign_a_citation_form(form)).to be_truthy
          end
          it 'will create an event log entry for the requesting user' do
            user = User.new(id: '123')
            expect { subject.submit_assign_a_citation_form(form, requested_by: user) }.
              to change { Models::EventLog.where(user: user, event_name: 'submit_assign_a_citation_form').count }.by(1)
          end
        end
      end

      context '#build_assign_a_citation_form object' do
        let(:header) { double }
        subject { Repository.new.build_assign_a_citation_form(header: header) }
        it { should respond_to :header }
        it { should respond_to :citation }
        it { should respond_to :type }
        it { should respond_to :submit }
      end

      it { should respond_to :citation_already_assigned? }
    end
  end
end