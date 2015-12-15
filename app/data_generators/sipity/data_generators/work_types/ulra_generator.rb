require 'active_support/core_ext/array/wrap'
require 'sipity/parameters/notification_context_parameter'
require 'sipity/data_generators/email_notification_generator'

module Sipity
  module DataGenerators
    module WorkTypes
      # Responsible for generating the work types within the ETD.
      class UlraGenerator
        WORK_TYPE_NAMES = [
          Models::WorkType::ULRA_SUBMISSION
        ]
        PROCESSING_ROLE_NAMES = [
          Models::Role::CREATING_USER,
          Models::Role::ADVISOR,
          Models::Role::DATA_OBSERVER,
          Models::Role::ULRA_REVIEWER
        ]
        ULRA_REVIEW_COMMITTEE_GROUP_NAME = 'ULRA Review Committee'

        def self.call(**keywords)
          new(**keywords).call
        end

        def initialize(work_area:, submission_window:, **keywords)
          self.submission_window = submission_window
          self.work_area = work_area
        end

        private

        attr_accessor :submission_window, :work_area

        public

        def call
          associate_work_types_and_their_state_machines_with_submission_window!
        end

        private

        def associate_work_types_and_their_state_machines_with_submission_window!
          WORK_TYPE_NAMES.each do |work_type_name|
            DataGenerators::FindOrCreateWorkType.call(name: work_type_name) do |work_type, processing_strategy, initial_state|
              assign_submission_window_work_type(work_type: work_type)
              assign_ulra_review_committee_to_ulra_role_for(processing_strategy: processing_strategy)
              generate_state_diagram(processing_strategy: processing_strategy, initial_state: initial_state)
            end
          end
        end

        def assign_submission_window_work_type(work_type:)
          Models::SubmissionWindowWorkType.find_or_create_by!(work_type: work_type, submission_window: submission_window)
        end

        def assign_ulra_review_committee_to_ulra_role_for(processing_strategy:)
          group = Models::Group.find_or_create_by!(name: ULRA_REVIEW_COMMITTEE_GROUP_NAME)
          PermissionGenerator.call(actors: group, roles: ['ulra_reviewer'], strategy: processing_strategy)
        end

        def generate_state_diagram(processing_strategy:, initial_state:)
          initial_state_name = initial_state.name.to_sym
          {
            start_a_submission: {
              transition_to: initial_state_name,
              emails: {
                confirmation_of_ulra_submission_started: { to: 'creating_user' },
                faculty_assigned_for_ulra_submission: { to: 'advisor' }
              }
            },
            debug: {
              states: {
                initial_state_name => { roles: ['ulra_reviewer'] },
                under_review: { roles: ['ulra_reviewer'] },
                pending_advisor_completion: { roles: ['ulra_reviewer'] },
                pending_student_completion: { roles: ['ulra_reviewer'] },
                review_completed: { roles: ['ulra_reviewer'] }
              }, attributes: { presentation_sequence: 2 }
            },
            show: {
              states: {
                initial_state_name => { roles: ['creating_user', 'advisor', 'ulra_reviewer'] },
                under_review: { roles: ['creating_user', 'advisor', 'ulra_reviewer'] },
                pending_advisor_completion: { roles: ['creating_user', 'advisor', 'ulra_reviewer'] },
                pending_student_completion: { roles: ['creating_user', 'advisor', 'ulra_reviewer'] },
                review_completed: { roles: ['creating_user', 'advisor', 'ulra_reviewer'] }
              }, attributes: { presentation_sequence: 1 }
            },
            destroy: {
              states: {
                initial_state_name => { roles: ['creating_user', 'ulra_reviewer'] },
                pending_advisor_completion: { roles: ['creating_user', 'ulra_reviewer'] },
                pending_student_completion: { roles: ['creating_user', 'ulra_reviewer'] },
                under_review: { roles: ['ulra_reviewer'] }
              }, attributes: { presentation_sequence: 3 }
            },
            project_information: {
              states: {
                initial_state_name => { roles: ['creating_user'] },
                pending_student_completion: { roles: ['creating_user'] },
                pending_advisor_completion: { roles: ['creating_user'] }
              }, attributes: { presentation_sequence: 1 }
            },
            attach: {
              states: {
                initial_state_name => { roles: ['creating_user'] },
                pending_student_completion: { roles: ['creating_user'] },
                pending_advisor_completion: { roles: ['creating_user'] },
                under_review: { roles: ['creating_user'] }
              }, attributes: { presentation_sequence: 2 }
            },
            access_policy: {
              states: {
                initial_state_name => { roles: ['creating_user', 'advisor'] },
                pending_student_completion: { roles: ['creating_user'] },
                pending_advisor_completion: { roles: ['creating_user', 'advisor'] },
                under_review: { roles: ['creating_user'] }
              }, attributes: { presentation_sequence: 3 }
            },
            plan_of_study: {
              states: {
                initial_state_name => { roles: ['creating_user'] },
                pending_student_completion: { roles: ['creating_user'] },
                pending_advisor_completion: { roles: ['creating_user'] }
              }, attributes: { presentation_sequence: 4 }
            },
            publisher_information: {
              states: {
                initial_state_name => { roles: ['creating_user'] },
                pending_student_completion: { roles: ['creating_user'] },
                pending_advisor_completion: { roles: ['creating_user'] }
              }, attributes: { presentation_sequence: 6 }
            },
            research_process: {
              states: {
                initial_state_name => { roles: ['creating_user'] },
                pending_student_completion: { roles: ['creating_user'] },
                pending_advisor_completion: { roles: ['creating_user'] }
              }, attributes: { presentation_sequence: 5 }
            },
            faculty_response: {
              states: {
                initial_state_name => { roles: ['advisor'] },
                pending_student_completion: { roles: ['advisor'] },
                pending_advisor_completion: { roles: ['advisor'] }
              }
            },
            submit_student_portion: {
              states: { initial_state_name => { roles: ['creating_user'] } },
              transition_to: :pending_advisor_completion,
              emails: { student_completed_their_portion_of_ulra: { to: 'advisor', cc: 'creating_user' } },
              required_actions: [:project_information, :attach, :access_policy, :plan_of_study, :publisher_information, :research_process]
            },
            submit_advisor_portion: {
              states: { initial_state_name => { roles: ['advisor'] } },
              transition_to: :pending_student_completion,
              emails: { faculty_completed_their_portion_of_ulra: { to: 'creating_user', cc: 'advisor' } },
              required_actions: [:access_policy, :faculty_response]
            },
            submit_for_review: {
              states: {
                pending_student_completion: { roles: ['creating_user'] },
                pending_advisor_completion: { roles: ['advisor'] }
              },
              transition_to: :under_review,
              emails: { confirmation_of_submitted_to_ulra_committee: { to: 'creating_user', cc: 'advisor' } },
              required_actions: [:attach, :plan_of_study, :publisher_information, :research_process, :faculty_response]
            },
            submit_completed_review: {
              states: { under_review: { roles: 'ulra_reviewer' } },
              transition_to: :review_completed
            }
          }.each do |action_name, action_config|
            action = Models::Processing::StrategyAction.find_or_create_by!(strategy: processing_strategy, name: action_name.to_s)
            if action_config.key?(:attributes)
              action_attributes = action_config.fetch(:attributes).stringify_keys
              existing_action_attributes = action.attributes.slice(*action_attributes.keys)
              unless action_attributes == existing_action_attributes
                action.update_attributes!(action_attributes)
              end
            end

            # Strategy State
            action_config.fetch(:states, {}).each do |state_name, state_config|
              strategy_state = Models::Processing::StrategyState.find_or_create_by!(strategy: processing_strategy, name: state_name.to_s)
              PermissionGenerator.call(
                actors: [],
                roles: state_config.fetch(:roles),
                strategy_state: strategy_state,
                action_names: action_name,
                strategy: processing_strategy
              )
            end

            # Prerequisites
            if action_config.key?(:transition_to)
              transition_to_state = Models::Processing::StrategyState.find_or_create_by!(strategy: processing_strategy, name: action_config.fetch(:transition_to).to_s)
              if action.resulting_strategy_state != transition_to_state
                action.resulting_strategy_state = transition_to_state
                action.action_type = action.default_action_type
                action.save!
              end
            end

            # Required Actions
            if action_config.key?(:required_actions)
              Array.wrap(action_config.fetch(:required_actions)).each do |required_action_name|
                prerequisite_action = Models::Processing::StrategyAction.find_or_create_by!(strategy: processing_strategy, name: required_action_name)
                prerequisite_action.update!(completion_required: true) unless prerequisite_action.completion_required?
                Models::Processing::StrategyActionPrerequisite.find_or_create_by!(guarded_strategy_action: action, prerequisite_strategy_action: prerequisite_action)
              end
            end

            action_config.fetch(:emails, {}).each do |email_name, recipients|
              EmailNotificationGenerator.call(
                strategy: processing_strategy, email_name: email_name, recipients: recipients, scope: action_name,
                reason: Parameters::NotificationContextParameter::REASON_ACTION_IS_TAKEN
              )
            end
          end
        end
      end
    end
  end
end
