module Sipity
  module Models
    # A conceptual container of when things can be added to the given WorkArea
    class SubmissionWindow < ActiveRecord::Base
      self.table_name = 'sipity_submission_windows'

      belongs_to :work_area

      def slug=(value)
        super(PowerConverter.convert(value, to: :slug))
      end
    end
  end
end
