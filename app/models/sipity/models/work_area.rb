module Sipity
  module Models
    # A WorkArea is a container for performing common work against a
    # heterogenious set of Work Types.
    #
    # It provides a :slug for a routable location and customization.
    #
    # @see Sipity::DataGenerators::FindOrCreateWorkArea for how to bootstrap a Work
    #   Area in the system.
    class WorkArea < ActiveRecord::Base
      self.table_name = 'sipity_work_areas'

      has_many :submission_windows, dependent: :destroy
      has_many :work_submissions, dependent: :destroy

      Processing.configure_as_a_processible_entity(self)

      has_one :strategy_usage, as: :usage, class_name: 'Sipity::Models::Processing::StrategyUsage', dependent: :destroy

      delegate :to_s, to: :name

      # @!attribute [rw] slug
      #
      #   A URI safe string that can be used as a "directory" of an application
      #   route. It is also the surrogate key for this model; In other words
      #   you can reference the WorkArea by its slug (instead of primary key
      #   :id).
      #
      #   @return [String] A URI safe string.

      def slug=(value)
        super(PowerConverter.convert(value, to: :slug))
      end

      # @!attribute [rw] partial_suffix
      #
      #   A file system safe string that can be used to assist with rendering
      #   of the work area (or its related concerns).
      #
      #   @return [String] A file system safe string.
      #   @note Experimental in its concern. We could derive this from the slug.

      def partial_suffix=(value)
        super(PowerConverter.convert(value, to: :file_system_safe_file_name))
      end

      # @!attribute [rw] demodulized_class_prefix_name
      #
      #   A string that is a valid demondulized class name (i.e. Hello is valid
      #   Hello::World would not be). This is to be used for determining a
      #   class for a given concept (i.e. Sipity::Forms::HelloForm).
      #
      #   @return [String] A string that when classified equals itself.
      #   @note Experimental in its concern. We could derive this from the slug.

      def demodulized_class_prefix_name=(value)
        super(PowerConverter.convert(value, to: :demodulized_class_name))
      end

      after_initialize :assign_values_from_slug

      private

      def assign_values_from_slug
        self.partial_suffix ||= slug
        self.demodulized_class_prefix_name ||= slug
      end
    end
  end
end
