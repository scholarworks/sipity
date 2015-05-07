require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe WorkSubmissionForms do
      before do
        module MockEtd
          module WorkSubmissions
            class DoFunThingForm
              def initialize(**_keywords)
              end
            end
          end
        end
        module Core
          module WorkSubmissions
            class FallbackForm
              def initialize(**_keywords)
              end
            end
          end
        end
      end
      after do
        Forms.send(:remove_const, :MockEtd)
        # Because autoload doesn't like me removing "live" modules
        Forms::Core::WorkSubmissions.send(:remove_const, :FallbackForm)
      end

      context '#build_the_form' do
        let(:work_area) { Models::WorkArea.new(demodulized_class_prefix_name: 'MockEtd') }
        let(:work) { Models::Work.new }
        let(:processing_action_name) { 'do_fun_thing' }
        before { expect(work).to receive(:work_area).and_return(work_area) }
        it 'will use the work area and action name to find the correct object' do
          expect(
            described_class.build_the_form(
              work: work, processing_action_name: processing_action_name, attributes: {}
            )
          ).to be_a(Forms::MockEtd::WorkSubmissions::DoFunThingForm)
        end

        it 'will fall back to the core namespace' do
          expect(
            described_class.build_the_form(
              work: work, processing_action_name: 'fallback', attributes: {}
            )
          ).to be_a(Forms::Core::WorkSubmissions::FallbackForm)
        end

        it 'will raise an exception if neither is found' do
          expect do
            described_class.build_the_form(work: work, processing_action_name: 'missing', attributes: {})
          end.to raise_error(NameError)
        end
      end
    end
  end
end
