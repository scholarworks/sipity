require 'spec_helper'

module Sipity
  module Queries
    RSpec.describe WorkAreaQueries, type: :isolated_repository_module do
      let(:work_area) do
        Models::WorkArea.new(name: 'worm', slug: 'worm', partial_suffix: 'worm', demodulized_class_prefix_name: 'Worm')
      end
      context '#find_works_area_by' do
        it 'will find by slug' do
          work_area.save!
          expect(test_repository.find_work_area_by(slug: work_area.slug)).to eq(work_area)
        end

        it 'will raise an exception if none is found' do
          expect { test_repository.find_work_area_by(slug: 'another') }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
      context '#build_work_area_processing_action_form' do
        let(:parameters) { { work_area: double, processing_action_name: double, attributes: double } }
        let(:form) { double }
        it 'will delegate the heavy lifting to a builder' do
          expect(Forms::WorkAreas).to receive(:build_the_form).with(parameters.merge(repository: test_repository)).and_return(form)
          expect(test_repository.build_work_area_processing_action_form(parameters)).to eq(form)
        end
      end
    end
  end
end
