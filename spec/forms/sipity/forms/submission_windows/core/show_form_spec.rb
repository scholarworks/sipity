require 'spec_helper'
require 'sipity/forms/submission_windows/core/show_form'
require 'sipity/forms/submission_windows/core/show_form'

module Sipity
  module Forms
    module SubmissionWindows
      module Core
        RSpec.describe ShowForm do
          let(:processing_action_name) { 'show' }
          let(:submission_window) { double }
          subject { described_class.new(submission_window: submission_window, processing_action_name: processing_action_name) }

          its(:policy_enforcer) { is_expected.to eq Sipity::Policies::SubmissionWindowPolicy }
          its(:processing_action_name) { is_expected.to eq processing_action_name }

          it { is_expected.to be_a(Models::SubmissionWindow) }
        end
      end
    end
  end
end
