require 'active_support/core_ext/array/wrap'

module Sipity
  module DataGenerators
    module WorkTypes
      # Responsible for generating the work types within the ETD.
      class SelfDepositGenerator
        WORK_TYPE_NAMES = [
          Models::WorkType::DOCUMENT
        ]
        PROCESSING_ROLE_NAMES = [
          Models::Role::CREATING_USER
        ]

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
              generate_state_diagram(processing_strategy: processing_strategy, initial_state: initial_state)
            end
          end
        end

        def generate_state_diagram(processing_strategy:, initial_state:)
          {
            start_a_submission: {
              states: {
                initial_state.name.to_sym => { roles: ['creating_user'] }
              },
              transition_to: :new
            },
            show: {
              states: {
                initial_state.name.to_sym => { roles: ['creating_user'] },
                under_review: { roles: ['creating_user'] }
              }
            },
            describe: {
              states: { initial_state.name.to_sym => { roles: ['creating_user'] } }
            },
            collaborators: {
              states: { initial_state.name.to_sym => { roles: ['creating_user'] } }
            },
            attach: {
              states: { initial_state.name.to_sym => { roles: ['creating_user'] } }
            },
            access_policy: {
              states: { initial_state.name.to_sym => { roles: ['creating_user'] } }
            },
            affiliation: {
              states: { initial_state.name.to_sym => { roles: ['creating_user'] } }
            },
            search_terms: {
              states: { initial_state.name.to_sym => { roles: ['creating_user'] } }
            },
            submit_for_review: {
              states: {
                initial_state.name.to_sym => { roles: ['creating_user'] }
              },
              transition_to: :under_review,
              required_actions: [:describe, :attach, :affiliation, :access_policy]
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
