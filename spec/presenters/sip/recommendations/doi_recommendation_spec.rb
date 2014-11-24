require 'spec_helper'

module Sip
  module Recommendations
    RSpec.describe DoiRecommendation do
      let(:repository) { double(doi_request_is_pending?: false, doi_already_assigned?: false)}
      let(:header) { double('Header') }
      subject { described_class.new(header: header, repository: repository)}

      context 'when a doi exists in the system its' do
        before do
          expect(repository).to receive(:doi_already_assigned?).with(header).and_return(true)
        end
        its(:state) { should eq :doi_already_assigned }
        its(:status) { should eq :doi_already_assigned }
      end

      context 'when a doi does not exist in the system but a request was submitted its' do
        before do
          expect(repository).to receive(:doi_already_assigned?).with(header).and_return(false)
          expect(repository).to receive(:doi_request_is_pending?).with(header).and_return(true)
        end
        its(:state) { should eq :doi_request_is_pending }
        its(:status) { should eq :doi_request_is_pending }
      end

      context 'when a doi does not exist nor do we have record of a doi request its' do
        before do
          expect(repository).to receive(:doi_already_assigned?).with(header).and_return(false)
          expect(repository).to receive(:doi_request_is_pending?).with(header).and_return(false)
        end
        its(:state) { should eq :doi_not_assigned }
        its(:status) { should eq :doi_not_assigned }
      end
    end
  end
end
