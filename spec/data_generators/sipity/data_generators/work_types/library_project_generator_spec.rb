require 'rails_helper'
require 'sipity/data_generators/work_types/ulra_generator'

module Sipity
  module DataGenerators
    module WorkTypes
      # Responsible for generating the submission window for the ETD work area.
      RSpec.describe LibraryProjectGenerator do
        let(:work_area) { Models::WorkArea.new(id: 1, slug: 'library-project') }
        let(:submission_window) { Models::SubmissionWindow.new(id: 2, slug: 'propose', work_area_id: work_area.id) }
        subject { described_class.new(work_area: work_area, submission_window: submission_window) }

        its(:default_state_machine_generator) { should respond_to(:call) }
        its(:email_notification_generator) { should respond_to(:call) }

        it 'exposes .call as a convenience method' do
          expect_any_instance_of(described_class).to receive(:call)
          described_class.call(work_area: work_area, submission_window: submission_window)
        end

        it "will generate the state diagram for a ULRA submission" do
          expect(subject.send(:state_machine_generator)).to receive(:call).at_least(:once).and_call_original
          expect do
            subject.call
          end.to change { Models::SubmissionWindowWorkType.count }.by(described_class::WORK_TYPE_NAMES.count)
          # It can be called repeatedly without updating things
          [:update_attribute, :update_attributes, :update_attributes!, :save, :save!, :update, :update!].each do |method_names|
            expect_any_instance_of(ActiveRecord::Base).to_not receive(method_names)
          end
          subject.call
        end
      end
    end
  end
end
