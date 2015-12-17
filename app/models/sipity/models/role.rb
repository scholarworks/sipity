module Sipity
  module Models
    # A named concept that represents a set of responsibilities/verbs.
    # Often confused for a Group. Group represents people.
    # Roles represent what can/is done by anything/anyone having the given role.
    #
    # @todo I would like to shift all roles to include a verb. So shift etd_reviewer to "Reviewing ETDs"
    #
    # @note Should this be in the Processing submodule? Perhaps. This model
    #   representes the "roles" that users of the system can have. It is not
    #   the "role" that they had in relation to the scholarly work that is
    #   being deposited (i.e. co-author on a paper).
    #
    # @see Sipity::Models::Collaborators
    # @see Sipity::Models::Processing::Actor
    class Role < ActiveRecord::Base
      self.table_name = 'sipity_roles'

      has_many(
        :processing_strategy_roles,
        dependent: :destroy,
        class_name: 'Sipity::Models::Processing::StrategyRole'
      )

      has_many(
        :email_recipients,
        dependent: :destroy,
        foreign_key: :role_id,
        class_name: 'Sipity::Models::Notification::EmailRecipient'
      )

      ADVISOR = 'advisor'.freeze
      APPROVING_PROJECTS = 'Approving Projects'.freeze
      BATCH_INGESTOR = 'batch_ingestor'.freeze
      CATALOGER = 'cataloger'.freeze
      CREATING_USER = 'creating_user'.freeze
      DATA_OBSERVER = 'data_observer'.freeze
      ETD_REVIEWER = 'etd_reviewer'.freeze
      MANAGING_PROJECTS = 'Managing Projects'.freeze
      SUBMISSION_WINDOW_VIEWER = 'submission_window_viewer'.freeze
      ULRA_REVIEWER = 'ulra_reviewer'.freeze
      WORK_AREA_MANAGER = 'work_area_manager'.freeze
      WORK_AREA_VIEWER = 'work_area_viewer'.freeze
      WORK_SUBMITTER = 'work_submitter'.freeze

      # As I don't have a means for assigning roles for a given processing type
      # I need a controlled vocabulary for roles.
      enum(
        name: {
          ADVISOR => ADVISOR,
          APPROVING_PROJECTS => APPROVING_PROJECTS,
          BATCH_INGESTOR => BATCH_INGESTOR,
          CATALOGER => CATALOGER,
          CREATING_USER => CREATING_USER,
          DATA_OBSERVER => DATA_OBSERVER,
          ETD_REVIEWER => ETD_REVIEWER,
          MANAGING_PROJECTS => MANAGING_PROJECTS,
          SUBMISSION_WINDOW_VIEWER => SUBMISSION_WINDOW_VIEWER,
          ULRA_REVIEWER => ULRA_REVIEWER,
          WORK_AREA_MANAGER => WORK_AREA_MANAGER,
          WORK_AREA_VIEWER => WORK_AREA_VIEWER,
          WORK_SUBMITTER => WORK_SUBMITTER
        }
      )

      def self.[](name)
        find_or_create_by!(name: name.to_s)
      end

      def self.valid_names
        names.keys
      end

      def to_s
        name
      end
    end
  end
end
