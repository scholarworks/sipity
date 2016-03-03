require 'active_support/core_ext/array/wrap'
require 'sipity/parameters/notification_context_parameter'

module Sipity
  module DataGenerators
    module WorkTypes
      # Responsible for generating the work types within the ETD.
      class LibraryProjectGenerator
        WORK_TYPE_NAMES = [
          Models::WorkType::LIBRARY_PROJECT_PROPOSAL
        ]
        PROCESSING_ROLE_NAMES = [
          Models::Role::CREATING_USER,
          Models::Role::MANAGING_PROJECTS,
          Models::Role::APPROVING_PROJECTS
        ]

        GROUP_NAME_LIBRARY_PROGRAM_DIRECTORS = 'Library Program Directors'
        GROUP_NAME_LIBRARY_PROJECT_MANAGERS = 'Library Project Managers'

        def self.call(**keywords)
          new(**keywords).call
        end

        def initialize(work_area:, submission_window:, **keywords)
          self.submission_window = submission_window
          self.work_area = work_area
          self.state_machine_generator = keywords.fetch(:state_machine_generator) { default_state_machine_generator }
          self.email_notification_generator = keywords.fetch(:email_notification_generator) { default_email_notification_generator }
        end

        private

        attr_accessor :submission_window, :work_area, :state_machine_generator, :email_notification_generator

        def default_state_machine_generator
          require 'sipity/data_generators/state_machine_generator'
          DataGenerators::StateMachineGenerator.method(:call)
        end

        def default_email_notification_generator
          require 'sipity/data_generators/email_notification_generator'
          DataGenerators::EmailNotificationGenerator.method(:call)
        end

        public

        def call
          associate_work_types_and_their_state_machines_with_submission_window!
        end

        private

        def associate_work_types_and_their_state_machines_with_submission_window!
          WORK_TYPE_NAMES.each do |work_type_name|
            DataGenerators::FindOrCreateWorkType.call(name: work_type_name) do |work_type, processing_strategy, initial_state|
              assign_submission_window_work_type(work_type: work_type)
              assign_group_to_role_for(
                processing_strategy: processing_strategy,
                group_names: GROUP_NAME_LIBRARY_PROJECT_MANAGERS,
                role_names: Models::Role::MANAGING_PROJECTS
              )
              assign_group_to_role_for(
                processing_strategy: processing_strategy,
                group_names: [GROUP_NAME_LIBRARY_PROGRAM_DIRECTORS, GROUP_NAME_LIBRARY_PROJECT_MANAGERS],
                role_names: Models::Role::APPROVING_PROJECTS
              )
              generate_state_diagram(processing_strategy: processing_strategy, initial_state: initial_state)
            end
          end
        end

        def assign_submission_window_work_type(work_type:)
          Models::SubmissionWindowWorkType.find_or_create_by!(work_type: work_type, submission_window: submission_window)
        end

        def assign_group_to_role_for(processing_strategy:, group_names:, role_names:)
          Array.wrap(group_names).each do |group_name|
            group = Models::Group.find_or_create_by!(name: group_name)
            PermissionGenerator.call(actors: group, roles: role_names, strategy: processing_strategy)
          end
        end

        def generate_state_diagram(processing_strategy:, initial_state:)
          managing_projects = Models::Role::MANAGING_PROJECTS
          approving_projects = Models::Role::APPROVING_PROJECTS
          creating_user = Models::Role::CREATING_USER

          initial_state_name = initial_state.name.to_sym
          {
            start_a_submission: {
              transition_to: initial_state_name,
              emails: {
                confirmation_of_project_proposal_created: { to: creating_user }
              }
            },
            show: {
              states: {
                initial_state_name => { roles: [creating_user, managing_projects] },
                under_pmo_review: { roles: [creating_user, managing_projects] },
                under_director_review: { roles: [creating_user, managing_projects, approving_projects] },
                proposal_rejected: { roles: [creating_user, managing_projects] },
                proposal_accepted: { roles: [creating_user, managing_projects] },
              }, attributes: { presentation_sequence: 1 }
            },
            debug: {
              states: {
                initial_state_name => { roles: [managing_projects] },
                under_pmo_review: { roles: [managing_projects] },
                under_director_review: { roles: [managing_projects] },
                proposal_rejected: { roles: [managing_projects] },
                proposal_accepted: { roles: [managing_projects] },
              }, attributes: { presentation_sequence: 2 }
            },
            requester_information: {
              states: {
                initial_state_name => { roles: [creating_user] },
              }, attributes: { presentation_sequence: 1 }
            },
            project_information: {
              states: {
                initial_state_name => { roles: [creating_user] }
              }, attributes: { presentation_sequence: 2 }
            },
            completion_requirement: {
              states: {
                initial_state_name => { roles: [creating_user] },
              }, attributes: { presentation_sequence: 3 }
            },
            project_assignment: {
              states: {
                under_pmo_review: { roles: [managing_projects] }
              }, attributes: { presentation_sequence: 1 }
            },
            submit_for_pmo_review: {
              states: { initial_state_name => { roles: [creating_user] } },
              transition_to: :under_pmo_review,
              required_actions: [:requester_information, :project_information],
              emails: {
                confirmation_of_project_proposal_submitted: { to: creating_user },
                project_proposal_submitted_to_pmos: { to: managing_projects }
              }
            },
            approve: {
              states: {
                under_pmo_review: { roles: [managing_projects] },
                under_director_review: { roles: [managing_projects, approving_projects] }
              },
              required_actions: [:project_assignment],
              transition_to: :proposal_accepted,
              attributes: { presentation_sequence: 2 },
              emails: { project_proposal_accepted: { to: creating_user, cc: managing_projects } }
            },
            reject: {
              states: { under_pmo_review: { roles: [managing_projects] } },
              transition_to: :proposal_rejected,
              attributes: { presentation_sequence: 3 },
              emails: { project_proposal_rejected: { to: creating_user, cc: managing_projects } }
            },
            submit_for_director_review: {
              states: { under_pmo_review: { roles: [managing_projects] } },
              transition_to: :under_director_review,
              attributes: { presentation_sequence: 1 },
              required_actions: [:project_assignment],
              emails: { project_proposal_submitted_to_directors: { to: approving_projects, cc: [creating_user, managing_projects] } }
            }
          }.each do |action_name, action_config|
            state_machine_generator.call(processing_strategy: processing_strategy, action_name: action_name, config: action_config)
          end
        end
      end
    end
  end
end
