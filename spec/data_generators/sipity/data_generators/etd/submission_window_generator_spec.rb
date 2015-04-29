require 'rails_helper'

module Sipity
  module DataGenerators
    module Etd
      # Responsible for generating the submission window for the ETD work area.
      RSpec.describe SubmissionWindowGenerator do
        let(:work_area) { Models::WorkArea.new(id: 1, slug: 'etd') }
        let(:submission_window) { Models::SubmissionWindow.new(id: 2, slug: 'start', work_area_id: work_area.id) }
        subject { described_class }

        it 'will persist the submission window if it has not already been persisted' do
          expect { subject.call(submission_window: submission_window, work_area: work_area) }.
            to change { Models::SubmissionWindow.count }.by(1)
        end

        it 'will associate the configured work types to the submission window' do
          expect { subject.call(submission_window: submission_window, work_area: work_area) }.
            to change { Models::SubmissionWindowWorkType.count }.by(described_class::WORK_TYPE_NAMES.size)
        end

        it 'will grant permission to all authenticated users to create an ETD within the submission window'
      end
    end
  end
end
