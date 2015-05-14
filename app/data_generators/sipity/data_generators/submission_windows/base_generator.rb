module Sipity
  module DataGenerators
    module SubmissionWindows
      # Responsible for generating the submission window for the ETD work area.
      class BaseGenerator
        def self.call(**keywords)
          new(**keywords).call
        end

        def initialize(work_area:, submission_window:, **keywords)
          self.work_area = work_area
          self.submission_window = submission_window
          self.work_submitters = keywords.fetch(:work_submitters) { default_work_submitters }
          self.work_submitter_role = keywords.fetch(:work_submitter_role) { default_work_submitter_role }
        end

        private

        attr_reader :submission_window, :work_area
        attr_accessor :work_submitters, :work_submitter_role
        attr_reader :processing_strategy


        def default_work_submitter_role
          Models::Role::WORK_SUBMITTER
        end

        def work_area=(input)
          @work_area = PowerConverter.convert(input, to: :work_area)
        end

        def default_work_submitters
          Models::Group.all_registered_users
        end

        def submission_window=(input)
          @submission_window = PowerConverter.convert(input, to: :submission_window, scope: work_area)
        end

        public

        def call
          persist_submission_window_if_applicable!
          find_or_resuse_or_create_processing_strategy!
          find_or_create_submission_windows_processing_entity!
          grant_permissions_to_submission_actions!
          yield(submission_window, processing_strategy) if block_given?
        end

        private

        def persist_submission_window_if_applicable!
          submission_window.save! unless submission_window.persisted?
        end

        def find_or_resuse_or_create_processing_strategy!
          if submission_window.processing_strategy
            @processing_strategy = submission_window.processing_strategy
          else
            already_used_processing_strategy = Models::Processing::StrategyUsage.where(
              usage_id: work_area.submission_window_ids, usage_type: Conversions::ConvertToPolymorphicType.call(submission_window)
            ).first
            if already_used_processing_strategy
              @processing_strategy = already_used_processing_strategy
            else
              @processing_strategy = Models::Processing::Strategy.find_or_create_by!(
                name: "Submission Window #{work_area.slug} #{submission_window.slug} processing"
              )
            end
          end
        end

        def find_or_create_submission_windows_processing_entity!
          submission_window.processing_entity || submission_window.create_processing_entity!(
            strategy: processing_strategy, strategy_state: processing_strategy.initial_strategy_state
          )
          Models::Processing::StrategyUsage.find_or_create_by!(strategy: processing_strategy, usage: submission_window)
        end

        SUBMISSION_WINDOW_ACTION_NAMES = ['show', 'start_a_submission'].freeze

        def grant_permissions_to_submission_actions!
          PermissionGenerator.call(
            actors: work_submitters,
            roles: work_submitter_role,
            action_names: SUBMISSION_WINDOW_ACTION_NAMES,
            entity: submission_window,
            strategy: processing_strategy,
            strategy_state: processing_strategy.initial_strategy_state
          )
        end
      end
    end
  end
end
