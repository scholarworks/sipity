require 'rails_helper'
require 'sipity/data_generators/find_or_create_submission_window'

module Sipity
  module DataGenerators
    RSpec.describe FindOrCreateSubmissionWindow do
      subject { described_class }
      let(:work_area) { Models::WorkArea.new(slug: 'etd', id: 1, demodulized_class_prefix_name: 'Etd', partial_suffix: 'etd') }
      let(:strategy_id) { 888_999_111 }
      let(:slug) { 'start' }
      before do
        allow(Sipity::DataGenerators::SubmissionWindows::EtdGenerator).to receive(:call)
        allow(Sipity::DataGenerators::WorkTypeGenerator).to receive(:generate_from_json_file)
      end
      it 'will create a submission window for the given work area' do
        expect { subject.call(slug: slug, work_area: work_area, open_for_starting_submissions_at: Time.zone.now) }.
          to change(Models::SubmissionWindow, :count).by(1)
      end
      it 'will yield the created submission window' do
        expect { |b| subject.call(slug: slug, work_area: work_area, &b) }.
          to yield_with_args(Models::SubmissionWindow)
      end

      it 'can be called repeatedly without updating things' do
        subject.call(slug: slug, work_area: work_area)
        [:update_attribute, :update_attributes, :update_attributes!, :save, :save!, :update, :update!].each do |method_names|
          expect_any_instance_of(ActiveRecord::Base).to_not receive(method_names)
        end
        subject.call(slug: slug, work_area: work_area)
      end

      it 'will leverage the custom etd processing generator' do
        expect(Sipity::DataGenerators::SubmissionWindows::EtdGenerator).
          to receive(:call).with(work_area: work_area, submission_window: be_persisted)
        expect(Sipity::DataGenerators::WorkTypeGenerator).
          to receive(:generate_from_json_file).with(submission_window: be_persisted, path: kind_of(Pathname))
        subject.call(slug: slug, work_area: work_area)
      end

    end
  end
end
