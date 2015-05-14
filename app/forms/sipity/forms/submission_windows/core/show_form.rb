module Sipity
  module Forms
    module SubmissionWindows
      module Core
        # Responsible for "showing" a Submission Window.
        #
        # @note This is the result of changing the SubmissionsWindows controller
        #   to be two actions.
        class ShowForm < Decorators::ComparableDelegateClass(Models::SubmissionWindow)
          class_attribute :policy_enforcer
          self.policy_enforcer = Sipity::Policies::SubmissionWindowPolicy

          def initialize(submission_window:, processing_action_name:, **_keywords)
            self.submission_window = submission_window
            self.processing_action_name = processing_action_name
            super(submission_window)
          end

          attr_reader :processing_action_name

          private

          attr_writer :processing_action_name
          attr_accessor :submission_window
        end
      end
    end
  end
end
