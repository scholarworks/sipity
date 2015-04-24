module Sipity
  module Models
    # Providing a "persistence" layer for various work types. This is the
    # canonical source for all work types.
    #
    # One reason for the class is that I want translations. This is something
    # that will be added later as it is not a primary concern.
    class WorkType < ActiveRecord::Base
      self.table_name = 'sipity_work_types'

      NAMED_WORK_TYPES_FOR_ENUM = {
        'doctoral_dissertation' => 'doctoral_dissertation',
        'master_thesis' => 'master_thesis'
      }.freeze

      has_many :submission_window_work_types, dependent: :destroy

      # As I don't have a means for assigning roles for a given processing type
      # I need a controlled vocabulary for roles.
      enum(name: NAMED_WORK_TYPES_FOR_ENUM)

      def self.[](name)
        where(name: name.to_s).first!
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

      has_one :default_processing_strategy, as: :proxy_for, class_name: 'Sipity::Models::Processing::Strategy', dependent: :destroy

      def find_or_initialize_default_processing_strategy(&block)
        if default_processing_strategy
          yield(default_processing_strategy) if block_given?
          default_processing_strategy
        elsif block_given?
          build_default_processing_strategy(name: "#{name} processing", &block)
        else
          build_default_processing_strategy(name: "#{name} processing")
        end
      end
    end
  end
end
