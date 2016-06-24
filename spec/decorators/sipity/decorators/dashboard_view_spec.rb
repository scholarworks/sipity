require 'spec_helper'

module Sipity
  module Decorators
    RSpec.describe DashboardView do
      let(:repository) { double('Repository') }
      let(:filter) { { processing_state: 'chicken' } }
      let(:user) { double('User') }
      subject { described_class.new(repository: repository, filter: filter, user: user, page: 1) }
      it 'will have a #search_path' do
        expect(subject.search_path).to be_a(String)
      end
      it 'will have #filterable_processing_states' do
        expect(subject.filterable_processing_states).to be_a(Array)
      end
      it 'will have decorated #works' do
        decorator = double
        works = [double, double("Toil and Trouble")]
        expect(repository).to receive(:find_works_via_search).and_return(works)
        allow(decorator).to receive(:new).with(works[0]).and_return(works[0])
        allow(decorator).to receive(:new).with(works[1]).and_return(works[1])
        expect(subject.works).to eq(works)
      end

      its(:default_repository) { is_expected.to respond_to(:find_works_via_search) }
      its(:processing_state) { is_expected.to eq(filter.fetch(:processing_state)) }
    end
  end
end
