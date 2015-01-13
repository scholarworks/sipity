require 'rails_helper'

module Sipity
  module Queries
    RSpec.describe CitationQueries, type: :repository_methods do
      context '#build_assign_a_citation_form object' do
        let(:work) { double }
        subject { test_repository.build_assign_a_citation_form(work: work) }
        it { should respond_to :work }
        it { should respond_to :citation }
        it { should respond_to :type }
        it { should respond_to :submit }
      end

      context '#citation_already_assigned?' do
        it 'will query the work' do
          work = Models::Sip.new(id: 1)
          expect(test_repository.citation_already_assigned?(work)).to eq(false)
        end
      end
    end
  end
end
