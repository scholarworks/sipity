module Sipity
  module Models
    # A conceptual container of when things can be added to the given WorkArea
    class SubmissionWindow < ActiveRecord::Base
      self.table_name = 'sipity_submission_windows'

      belongs_to :work_area

      has_many :submission_window_work_types, dependent: :destroy

      has_many :work_types, through: :submission_window_work_types

      def slug=(value)
        super(PowerConverter.convert(value, to: :slug))
      end
    end
  end
end
