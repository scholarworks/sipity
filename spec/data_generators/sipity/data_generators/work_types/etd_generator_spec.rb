require 'rails_helper'

module Sipity
  module DataGenerators
    module WorkTypes
      # Responsible for generating the submission window for the ETD work area.
      RSpec.describe EtdGenerator do
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
              expect do
                subject.call(work_area: work_area, submission_window: submission_window)
              end.to change { Models::WorkType.count }.by(described_class::WORK_TYPE_NAMES.count)
            end.to change { Models::Processing::Strategy.count }.by(described_class::WORK_TYPE_NAMES.count)
          end.to change { Models::SubmissionWindowWorkType.count }.by(described_class::WORK_TYPE_NAMES.count)

          # And it can be called multiple times without changes.
          [:update_attribute, :update_attributes, :update_attributes!, :save, :save!, :update, :update!].each do |method_names|
            expect_any_instance_of(ActiveRecord::Base).to_not receive(method_names)
          end
          subject.call(submission_window: submission_window, work_area: work_area)
        end
      end
    end
  end
end
