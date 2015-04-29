require 'rails_helper'

module Sipity
  module DataGenerators
    module Etd
      # Responsible for generating the submission window for the ETD work area.
      RSpec.describe SubmissionWindowProcessingGenerator do
        let(:work_area) { Models::WorkArea.new(id: 1, slug: 'etd') }
        let(:submission_window) { Models::SubmissionWindow.new(id: 2, slug: 'start', work_area_id: work_area.id) }
        subject { described_class }

        it 'will persist the submission window if it has not already been persisted' do
          expect { subject.call(submission_window: submission_window, work_area: work_area) }.
            to change { Models::SubmissionWindow.count }.by(1)
        end

        it 'will associate the configured work types to the submission window' do
          described_class::WORK_TYPE_NAMES.each do |work_type_name|
            expect(DataGenerators::FindOrCreateWorkType).to receive(:call).with(name: work_type_name)
          end
          subject.call(submission_window: submission_window, work_area: work_area)
        end

        it 'will grant permission to all authenticated users to create an ETD within the submission window'
      end
    end
  end
end
