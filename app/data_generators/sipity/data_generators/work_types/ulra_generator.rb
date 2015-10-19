require 'active_support/core_ext/array/wrap'

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
              assign_ulra_review_committee_to_ulra_role_for(processing_strategy: processing_strategy)
              generate_state_diagram(processing_strategy: processing_strategy, initial_state: initial_state)
            end
          end
        end

        def assign_ulra_review_committee_to_ulra_role_for(processing_strategy:)
          group = Cogitate::Client.encoded_identifier_for(strategy: 'group', identifying_value: 'ULRA Review Committee')
          PermissionGenerator.call(actors: group, roles: ['ulra_reviewer'], strategy: processing_strategy)
        end

        def generate_state_diagram(processing_strategy:, initial_state:)
          {
            show: {
              states: {
                initial_state.name.to_sym => { roles: ['creating_user', 'advisor', 'ulra_reviewer'] },
                under_review: { roles: ['creating_user', 'advisor', 'ulra_reviewer'] }
              }
            },
            destroy: {
              states: {
                initial_state.name.to_sym => { roles: ['creating_user', 'ulra_reviewer'] },
                under_review: { roles: ['ulra_reviewer'] }
              }
            },
            plan_of_study: {
              states: { initial_state.name.to_sym => { roles: ['creating_user'] } }
            },
            publisher_information: {
              states: { initial_state.name.to_sym => { roles: ['creating_user'] } }
            },
            research_process: {
              states: { initial_state.name.to_sym => { roles: ['creating_user'] } }
            },
            faculty_comments: {
              states: { initial_state.name.to_sym => { roles: ['advisor'] } }
            },
            submit_for_review: {
              states: {
                initial_state.name.to_sym => { roles: ['creating_user', 'advisor'] }
              },
              transition_to: :under_review,
              required_actions: [:plan_of_study, :publisher_information, :research_process, :faculty_response]
            },
            submit_completed_review: {
              states: { under_review: { roles: 'ulra_reviewer' } },
              transition_to: :review_completed
            }
          }.each do |action_name, action_config|
            action = Models::Processing::StrategyAction.find_or_create_by!(strategy: processing_strategy, name: action_name.to_s)

            # Strategy State
            action_config.fetch(:states).each do |state_name, state_config|
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
          end
        end
      end
    end
  end
end
