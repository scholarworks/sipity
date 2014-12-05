require 'spec_helper'

module Sipity
  module Decorators
    module Recommendations
      RSpec.describe CitationRecommendation do
        let(:repository) { double(citation_already_assigned?: false) }
        let(:helper) { double(header_citation_path: true) }
        let(:header) { double('Header', title: 'Hello World') }
        subject { described_class.new(header: header, repository: repository, helper: helper) }

        it { should respond_to :human_attribute_name }

        its(:human_name) { should be_a(String) }
        its(:human_status) { should be_a(String) }

        it 'will have a :path_to_recommendation' do
          expect(helper).to receive(:header_citation_path).with(header).and_return('/the/path')
          expect(subject.path_to_recommendation).to eq('/the/path')
        end

        context 'when a citation exists in the system its' do
          before do
            expect(repository).to receive(:citation_already_assigned?).with(header).and_return(true)
          end
          its(:state) { should eq :citation_already_assigned }
          its(:status) { should eq :citation_already_assigned }
        end

        context 'when a citation does not exist nor do we have record of a citation request its' do
          before do
            expect(repository).to receive(:citation_already_assigned?).with(header).and_return(false)
          end
          its(:state) { should eq :citation_not_assigned }
          its(:status) { should eq :citation_not_assigned }
        end
      end
    end
  end
end
