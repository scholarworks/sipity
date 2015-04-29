module Sipity
  module DataGenerators
    module Etd
      # Responsible for generating the submission window for the ETD work area.
      class SubmissionWindowGenerator
        def self.call(**keywords)
          new(**keywords).call
        end

        def initialize(submission_window:)
          self.submission_window = submission_window
        end

        private

        attr_accessor :submission_window

        public

        def call
          # create_or_associate_masters_thesis_work_type
          # create_or_associate_doctoral_dissertation_work_type
        end
      end
    end
  end
end
