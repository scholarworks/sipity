require 'rails_helper'

module Sipity
  module DataGenerators
    module Etd
      # Responsible for generating the submission window for the ETD work area.
      RSpec.describe WorkTypesProcessingGenerator do
        let(:work_area) { Models::WorkArea.new(id: 1, slug: 'etd') }
        let(:submission_window) { Models::SubmissionWindow.new(id: 2, slug: 'start', work_area_id: work_area.id) }
        subject { described_class }

        it "will generate the state diagram for the master thesis and doctoral dissertation" do
          # Consider running this code and checking against the output state machine
          # This was how I visually validated the changes.
          #
          # However this test is much more of a bare-bones sanity check.
          expect do
            expect do
              subject.call(work_area: work_area, submission_window: submission_window)
            end.to change { Models::WorkType.count }.by(described_class::WORK_TYPE_NAMES.count)
          end.to change { Models::Processing::Strategy.count }.by(described_class::WORK_TYPE_NAMES.count)
        end
      end
    end
  end
end
