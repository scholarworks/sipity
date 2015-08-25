require 'rails_helper'
require 'sipity/data_generators/submission_windows/base_generator'
require 'sipity/data_generators/submission_windows/base_generator'

module Sipity
  module DataGenerators
    module SubmissionWindows
      # Responsible for generating the submission window for the ETD work area.
      RSpec.describe BaseGenerator do
        let(:work_area) { Models::WorkArea.new(id: 1, slug: 'etd') }
        let(:submission_window) { Models::SubmissionWindow.new(slug: 'start', work_area_id: work_area.id) }
        subject { described_class }

        it 'will persist records as expected (see spec for details)' do
          expect do
            expect do
              subject.call(submission_window: submission_window, work_area: work_area)
              # The SubmissionWindow is persisted if that was not the case already
            end.to change { Models::SubmissionWindow.count }.by(1)
            # Only one strategy state is created for an ETD; As things get moving
            # we may say that ETDs will have a more meaningful submission window:
            # * New
            # * Open For Submissions
            # * Closed for Submissions
          end.to change { Models::Processing::StrategyState.count }.by(1)
        end

        it 'will create a processing entity and strategy usage for the submission window' do
          subject.call(submission_window: submission_window, work_area: work_area)
          expect(submission_window.strategy_usage).to be_present
          expect(submission_window.processing_entity).to be_present
        end

        it 'will continue to use an assigned processing strategy' do
          processing_strategy = Models::Processing::Strategy.create!(id: 1, name: 'Ketchup')
          expect(submission_window).to receive(:processing_strategy).and_return(processing_strategy).at_least(:once)
          subject.call(submission_window: submission_window, work_area: work_area)
        end

        it 'will reuse a processing strategy assigned to the work area' do
          processing_strategy = Models::Processing::Strategy.create!(id: 1, name: 'Ketchup')
          expect(work_area).to receive(:submission_window_ids).and_return([999])
          expect(Models::Processing::StrategyUsage).to receive(:where).
            with(usage_id: [999], usage_type: Conversions::ConvertToPolymorphicType.call(submission_window)).
            and_return([processing_strategy])
          subject.call(submission_window: submission_window, work_area: work_area)
        end

        it 'will grant the given work_submitters the submission window actions' do
          user = Sipity::Factories.create_user
          subject.call(submission_window: submission_window, work_area: work_area, work_submitters: user)
          described_class::SUBMISSION_WINDOW_ACTION_NAMES.each do |action_name|
            permission_to_show_submission_window = Policies::Processing::ProcessingEntityPolicy.call(
              user: user, entity: submission_window, action_to_authorize: action_name
            )
            expect(permission_to_show_submission_window).to be_truthy
          end
        end

        it 'can called repeatedly without updating things' do
          subject.call(submission_window: submission_window, work_area: work_area)
          [:update_attribute, :update_attributes, :update_attributes!, :save, :save!, :update, :update!].each do |method_names|
            expect_any_instance_of(ActiveRecord::Base).to_not receive(method_names)
          end
          subject.call(submission_window: submission_window, work_area: work_area)
        end

        context 'default values' do
          subject { described_class.new(submission_window: submission_window, work_area: work_area) }
          its(:default_work_submitters) { should eq Models::Group.all_verified_netid_users }
          its(:default_work_submitter_role) { should eq Models::Role::WORK_SUBMITTER }
        end
      end
    end
  end
end
