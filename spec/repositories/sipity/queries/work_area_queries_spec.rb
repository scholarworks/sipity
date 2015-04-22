module Sipity
  module Queries
    RSpec.describe WorkAreaQueries, type: :isolated_repository_module do
      context '#find_works_area_for' do
        let(:work_area) { Models::WorkArea.create!(slug: 'worm', partial_suffix: 'worm', demodulized_class_prefix_name: 'Worm') }
        it 'will find by slug' do
          expect(test_repository.find_work_area_by(slug: work_area.slug)).to eq(work_area)
        end
      end
    end
  end
end
