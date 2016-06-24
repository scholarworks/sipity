require "rails_helper"
require 'sipity/forms/submission_windows'

module Sipity
  module Forms
    RSpec.describe SubmissionWindows do
      before do
        module SubmissionWindows
          module MockEtd
            class DoFunThingForm
              def initialize(**_keywords)
              end
            end
          end
        end
        module SubmissionWindows
          module Core
            class FallbackForm
              def initialize(**_keywords)
              end
            end
          end
        end
      end
      after do
        # Because autoload doesn't like me removing "live" modules
        Forms::SubmissionWindows::Core.send(:remove_const, :FallbackForm)
        Forms::SubmissionWindows.send(:remove_const, :MockEtd)
      end

      context '#build_the_form' do
        let(:work_area) { Models::WorkArea.new(demodulized_class_prefix_name: 'MockEtd') }
        let(:submission_window) { Models::SubmissionWindow.new(work_area: work_area) }
        let(:processing_action_name) { 'do_fun_thing' }
        it 'will use the work area and action name to find the correct object' do
          expect(
            described_class.build_the_form(
              submission_window: submission_window, processing_action_name: processing_action_name, attributes: {}, repository: double
            )
          ).to be_a(Forms::SubmissionWindows::MockEtd::DoFunThingForm)
        end

        it 'will fall back to the core namespace' do
          expect(
            described_class.build_the_form(
              submission_window: submission_window, processing_action_name: 'fallback', attributes: {}, repository: double
            )
          ).to be_a(Forms::SubmissionWindows::Core::FallbackForm)
        end

        it 'will raise an exception if neither is found' do
          expect do
            described_class.build_the_form(
              submission_window: submission_window, processing_action_name: 'missing', attributes: {}, repository: double
            )
          end.to raise_error(NameError)
        end
      end
    end
  end
end
