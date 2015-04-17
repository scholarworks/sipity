module Sipity
  module Models
    # Defines the valid WorkTypes for a given SubmissionWindow
    class SubmissionWindowWorkType < ActiveRecord::Base
      self.table_name = 'sipity_submission_window_work_types'
      belongs_to :submission_window
      belongs_to :work_type
    end
  end
end
