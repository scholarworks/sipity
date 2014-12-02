require 'rails_helper'

module Sip
  module Repo
    RSpec.describe CitationMethods, type: :repository do
      let!(:klass) do
        class TestRepository
          include CitationMethods
        end
      end
      subject { klass.new }
      after { Sip::Repo.send(:remove_const, :TestRepository) }

      subject { Repository.new }

      context '#submit_assign_a_citation_form' do
        let(:header) { FactoryGirl.build_stubbed(:sip_header, id: '1234') }
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