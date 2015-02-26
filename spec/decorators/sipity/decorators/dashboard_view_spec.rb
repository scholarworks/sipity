module Sipity
  module Decorators
    RSpec.describe DashboardView do
      let(:repository) { double('Repository') }
      let(:filter) { { processing_state: 'chicken' } }
      let(:user) { double('User') }
      subject { described_class.new(repository: repository, filter: filter, user: user) }
      it 'will have a #search_path' do
        expect(subject.search_path).to be_a(String)
      end
      it 'will have #filterable_processing_states' do
        expect(subject.filterable_processing_states).to be_a(Array)
      end
      it 'will have #works' do
        works = [double, double("Toil and Trouble")]
        expect(repository).to receive(:find_works_for).and_return(works)
        expect(subject.works).to eq(works)
      end

      its(:default_repository) { should respond_to(:find_works_for) }
      its(:processing_state) { should eq(filter.fetch(:processing_state)) }
    end
  end
end
