module Sipity
  module DataGenerators
    module SubmissionWindows
      # Responsible for generating the submission window for the ETD work area.
      class LibraryProjectGenerator < BaseGenerator
        self.submission_window_action_names = ['show', 'propose'].freeze
      end
    end
  end
end
