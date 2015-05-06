module Sipity
  module Models
    # Responsible for exposing the relationship between a
    #
    # * work_area
    # * submission_window
    # * work
    class WorkSubmission < ActiveRecord::Base
      self.table_name = 'sipity_work_submissions'
      belongs_to :work_area
      belongs_to :submission_window
      belongs_to :work
    end
  end
end
