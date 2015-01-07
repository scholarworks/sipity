require 'rails_helper'

module Sipity
  module Queries
    RSpec.describe CitationQueries, type: :repository_methods do
      context '#build_assign_a_citation_form object' do
        let(:sip) { double }
        subject { test_repository.build_assign_a_citation_form(sip: sip) }
        it { should respond_to :sip }
        it { should respond_to :citation }
        it { should respond_to :type }
        it { should respond_to :submit }
      end

      context '#citation_already_assigned?' do
        it 'will query the sip' do
          sip = Models::Sip.new(id: 1)
          expect(test_repository.citation_already_assigned?(sip)).to eq(false)
        end
      end
    end
  end
end
