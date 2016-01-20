module Sipity
  module Models
    # Providing a "persistence" layer for various work types. This is the
    # canonical source for all work types.
    #
    # One reason for the class is that I want translations. This is something
    # that will be added later as it is not a primary concern.
    class WorkType < ActiveRecord::Base
      self.table_name = 'sipity_work_types'

      # TODO: I believe we will need to push this into a database to say what
      #   are the valid work types to create.
      DOCTORAL_DISSERTATION = 'doctoral_dissertation'.freeze
      MASTER_THESIS = 'master_thesis'.freeze
      ULRA_SUBMISSION = 'ulra_submission'.freeze
      DOCUMENT = 'document'.freeze

      NAMED_WORK_TYPES_FOR_ENUM = {
        DOCTORAL_DISSERTATION => DOCTORAL_DISSERTATION,
        MASTER_THESIS => MASTER_THESIS,
        ULRA_SUBMISSION => ULRA_SUBMISSION,
        DOCUMENT => DOCUMENT
      }.freeze

      has_many :submission_window_work_types, dependent: :destroy

      # As I don't have a means for assigning roles for a given processing type
      # I need a controlled vocabulary for roles.
      enum(name: NAMED_WORK_TYPES_FOR_ENUM)

      def self.[](name)
        find_by!(name: name.to_s)
      end

      def self.valid_names
        names.keys
      end

      # Because the Work#work_type is being enforced via an enum; So I want the
      # Work object to not have to worry about translating the structure as it
      # has no knowledge of the underlying structure of the NAMED_WORK_TYPES
      def self.all_for_enum_configuration
        NAMED_WORK_TYPES_FOR_ENUM
      end

      has_one :strategy_usage, as: :usage, class_name: 'Sipity::Models::Processing::StrategyUsage', dependent: :destroy
    end
  end
end
