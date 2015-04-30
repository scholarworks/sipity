require 'rails_helper'

module Sipity
  module DataGenerators
    RSpec.describe FindOrCreateSubmissionWindow do
      subject { described_class }
      let(:work_area) { Models::WorkArea.new(slug: 'etd', id: 1, demodulized_class_prefix_name: 'Etd') }
      let(:strategy_id) { 888_999_111 }
      let(:slug) { 'start' }
      before do
        allow(Sipity::DataGenerators::Etd::SubmissionWindowProcessingGenerator).to receive(:call)
        allow(Sipity::DataGenerators::Etd::WorkTypesProcessingGenerator).to receive(:call)
      end
      it 'will create a submission window for the given work area' do
        expect { subject.call(slug: slug, work_area: work_area) }.
          to change(Models::SubmissionWindow, :count).by(1)
      end
      it 'will yield the created submission window' do
        expect { |b| subject.call(slug: slug, work_area: work_area, &b) }.
          to yield_with_args(Models::SubmissionWindow)
      end

      it 'will leverage the custom etd processing generator' do
        expect(Sipity::DataGenerators::Etd::SubmissionWindowProcessingGenerator).
          to receive(:call).with(work_area: work_area, submission_window: be_persisted, work_submitters: ['anyone'])
        expect(Sipity::DataGenerators::Etd::WorkTypesProcessingGenerator).
          to receive(:call).with(work_area: work_area, submission_window: be_persisted, work_submitters: ['anyone'])
        subject.call(slug: slug, work_area: work_area, work_submitters: ['anyone'])
      end

    end
  end
end
