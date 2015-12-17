require 'rails_helper'
require 'sipity/data_generators/submission_windows/library_project_generator'

module Sipity
  module DataGenerators
    module SubmissionWindows
      # Responsible for generating the submission window for the ETD work area.
      RSpec.describe LibraryProjectGenerator do
        subject { described_class }
        its(:submission_window_action_names) { should eq(['show', 'propose']) }
      end
    end
  end
end
