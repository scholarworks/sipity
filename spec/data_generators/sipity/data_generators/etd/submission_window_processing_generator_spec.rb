require 'rails_helper'

module Sipity
  module DataGenerators
    module Etd
      # Responsible for generating the submission window for the ETD work area.
      RSpec.describe SubmissionWindowProcessingGenerator do
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

        it 'will grant the given work_submitters the ability to create a work' do
          user = Sipity::Factories.create_user
          subject.call(submission_window: submission_window, work_area: work_area, work_submitters: user)
          permission_to_show_submission_window = Policies::Processing::ProcessingEntityPolicy.call(
            user: user, entity: submission_window, action_to_authorize: 'create_a_work'
          )
          expect(permission_to_show_submission_window).to be_truthy
        end

        it 'will grant the given work_submitters the ability to see the submission window' do
          user = Sipity::Factories.create_user
          subject.call(submission_window: submission_window, work_area: work_area, work_submitters: user)
          permission_to_show_submission_window = Policies::Processing::ProcessingEntityPolicy.call(
            user: user, entity: submission_window, action_to_authorize: 'show'
          )
          expect(permission_to_show_submission_window).to be_truthy
        end

        context 'default values' do
          subject { described_class.new(submission_window: submission_window, work_area: work_area) }
          its(:default_work_submitters) { should eq Models::Group.all_registered_users }
          its(:default_work_submitter_role) { should eq Models::Role::WORK_SUBMITTER }
        end
      end
    end
  end
end
