require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe SubmissionWindowForms do
      before do
        module MockEtd
          module SubmissionWindows
            class DoFunThingForm
              def initialize(**_keywords)
              end
            end
          end
        end
        module Core
          module SubmissionWindows
            class FallbackForm
              def initialize(**_keywords)
              end
            end
          end
        end
      end
      after do
        Forms.send(:remove_const, :MockEtd)
        Forms.send(:remove_const, :Core)
      end

      context '#build_the_form' do
        let(:work_area) { Models::WorkArea.new(demodulized_class_prefix_name: 'MockEtd') }
        let(:submission_window) { Models::SubmissionWindow.new(work_area: work_area) }
        let(:processing_action_name) { 'do_fun_thing' }
        it 'will use the work area and action name to find the correct object' do
          expect(
            described_class.build_the_form(
              submission_window: submission_window, processing_action_name: processing_action_name, attributes: {}
            )
          ).to be_a(Forms::MockEtd::SubmissionWindows::DoFunThingForm)
        end

        it 'will fall back to the core namespace' do
          expect(
            described_class.build_the_form(
              submission_window: submission_window, processing_action_name: 'fallback', attributes: {}
            )
          ).to be_a(Forms::Core::SubmissionWindows::FallbackForm)
        end

        it 'will raise an exception if neither is found' do
          expect do
            described_class.build_the_form(submission_window: submission_window, processing_action_name: 'missing', attributes: {})
          end.to raise_error(NameError)
        end
      end
    end
  end
end
