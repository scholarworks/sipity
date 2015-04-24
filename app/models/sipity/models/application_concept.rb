module Sipity
  module Models
    # Experimental
    #
    # Throughout the application I have the case in which I need to relate data-
    # concepts to class concepts; (i.e. WorkArea's have the same processing
    # estrategy).
    #
    # As I'm thinking about them, I believe the WorkType and the
    # ApplicationConcept are in close alignment. It just happens that a WorkType
    # already exists and does not make sense to shoe horn the WorkArea into the
    # WorkType concept.
    #
    # Perhaps as I work through this concept, I'll emerge with a better abstract
    # representation of both WorkTypes and the WorkArea concept.
    class ApplicationConcept < ActiveRecord::Base
      self.table_name = 'sipity_application_concepts'

      WORK_AREA_CLASS_NAME = 'Sipity::Models::WorkArea'.freeze
      enum(
        class_name: {
          WORK_AREA_CLASS_NAME => WORK_AREA_CLASS_NAME
        }
      )

      has_one :processing_strategy, as: :proxy_for, dependent: :destroy, class_name: 'Sipity::Models::Processing::Strategy'

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
    end
  end
end
