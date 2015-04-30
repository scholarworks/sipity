module Sipity
  module DataGenerators
    module Etd
      # Responsible for generating the submission window for the ETD work area.
      class SubmissionWindowProcessingGenerator
        def self.call(**keywords)
          new(**keywords).call
        end

        def initialize(work_area:, submission_window:, work_submitters: [])
          self.work_area = work_area
          self.submission_window = submission_window
          self.work_submitters = work_submitters
          self.work_submitter_role = Models::Role::WORK_SUBMITTER
        end

        private

        attr_reader :submission_window, :work_area, :work_submitters, :work_submitter_role
        attr_reader :processing_strategy

        def work_submitter_role=(input)
          @work_submitter_role = Conversions::ConvertToRole.call(input)
        end

        def work_area=(input)
          @work_area = PowerConverter.convert(input, to: :work_area)
        end

        def work_submitters=(input)
          @work_submitters = Array.wrap(input).map {|i| Conversions::ConvertToProcessingActor.call(i) }
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
            already_used = Models::Processing::StrategyUsage.where(usage_id: work_area.submission_window_ids, usage_type: submission_window.class).first
            if already_used
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

        SUBMISSION_WINDOW_ACTION_NAMES = ['show', 'create_a_work'].freeze

        def grant_permissions_to_submission_actions!
          strategy_role = Models::Processing::StrategyRole.find_or_create_by!(role: work_submitter_role, strategy: processing_strategy)
          work_submitters.each do |submitter|
            Models::Processing::EntitySpecificResponsibility.find_or_create_by!(
              strategy_role: strategy_role,
              entity: submission_window.processing_entity,
              actor: submitter
            )
          end
          SUBMISSION_WINDOW_ACTION_NAMES.each do |action_name|
            strategy_action = Models::Processing::StrategyAction.find_or_create_by!(
              strategy: processing_strategy, name: action_name, allow_repeat_within_current_state: true
            )
            state_action = Models::Processing::StrategyStateAction.find_or_create_by!(
              strategy_action: strategy_action, originating_strategy_state: processing_strategy.initial_strategy_state
            )
            Models::Processing::StrategyStateActionPermission.find_or_create_by!(
              strategy_role: strategy_role, strategy_state_action: state_action
            )
          end
        end
      end
    end
  end
end
