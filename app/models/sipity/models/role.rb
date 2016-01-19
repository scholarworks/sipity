module Sipity
  module Models
    # A role is a responsibility to do things. That is to take actions. It is
    # easy to conflate a person's role with the groups to which they belong.
    # A group is a set of people. The association of group with role
    # indicates that the set of people have the same responsibilities.
    #
    # By separating Group and Role, we expose a more rich system in which we
    # can talk about group membership separate from the group's
    # responsibility.
    #
    # Another way to think of it is that a Group is a marco that expands to
    # represent people. A Role is a macro that expands to represent
    # responsibilities. In keeping them separate we can model more rich
    # relationships.
    #
    # @note Roles should be verbs. They are what you do.
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

      ADVISING = 'advising'.freeze
      BATCH_INGESTING = "batch_ingesting".freeze
      CATALOGING = "cataloging".freeze
      CREATING_USER = 'creating_user'.freeze
      DATA_OBSERVING = "data_observing".freeze
      ETD_REVIEWING = "etd_reviewing".freeze
      SUBMISSION_WINDOW_VIEWING = "submission_window_viewing".freeze
      ULRA_REVIEWING = "ulra_reviewing".freeze
      WORK_AREA_MANAGING = "work_area_managing".freeze
      WORK_AREA_VIEWING = "work_area_viewing".freeze
      WORK_SUBMITTING = "work_submitting".freeze

      # As I don't have a means for assigning roles for a given processing type
      # I need a controlled vocabulary for roles.
      enum(
        name: {
          ADVISING => ADVISING,
          BATCH_INGESTING => BATCH_INGESTING,
          CATALOGING => CATALOGING,
          CREATING_USER => CREATING_USER,
          DATA_OBSERVING => DATA_OBSERVING,
          ETD_REVIEWING => ETD_REVIEWING,
          SUBMISSION_WINDOW_VIEWING => SUBMISSION_WINDOW_VIEWING,
          ULRA_REVIEWING => ULRA_REVIEWING,
          WORK_AREA_MANAGING => WORK_AREA_MANAGING,
          WORK_AREA_VIEWING => WORK_AREA_VIEWING,
          WORK_SUBMITTING => WORK_SUBMITTING
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
