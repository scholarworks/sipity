require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe SubmissionWindowForms do
      before do
        module SubmissionWindowForms
          module MockEtd
            module SubmissionWindows
              class DoFunThingForm
                def initialize(**_keywords)
                end
              end
            end
          end
        end
      end
      after do
        SubmissionWindowForms.send(:remove_const, :MockEtd)
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
          ).to be_a(SubmissionWindowForms::MockEtd::SubmissionWindows::DoFunThingForm)
        end
      end
    end
  end
end
