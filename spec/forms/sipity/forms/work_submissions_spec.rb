require "rails_helper"
require 'sipity/forms/work_submissions'

module Sipity
  module Forms
    RSpec.describe WorkSubmissions do
      before do
        module WorkSubmissions
          module MockEtd
            class DoFunThingForm
              def initialize(**_keywords)
              end
            end
          end
        end
        module WorkSubmissions
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
        Forms::WorkSubmissions.send(:remove_const, :MockEtd)
        Forms::WorkSubmissions::Core.send(:remove_const, :FallbackForm)
      end

      context '#build_the_form' do
        let(:work_area) { Models::WorkArea.new(demodulized_class_prefix_name: 'MockEtd') }
        let(:work) { Models::Work.new }
        let(:processing_action_name) { 'do_fun_thing' }
        before { expect(work).to receive(:work_area).and_return(work_area) }

        it 'will classify the action name' do
          expect(
            described_class.build_the_form(
              work: work, processing_action_name: 'do_fun_things', attributes: {}, repository: double
            )
          ).to be_a(Forms::WorkSubmissions::MockEtd::DoFunThingForm)
        end

        it 'will use the work area and action name to find the correct object' do
          expect(
            described_class.build_the_form(
              work: work, processing_action_name: processing_action_name, attributes: {}, repository: double
            )
          ).to be_a(Forms::WorkSubmissions::MockEtd::DoFunThingForm)
        end

        it 'will fall back to the core namespace' do
          expect(
            described_class.build_the_form(
              work: work, processing_action_name: 'fallback', attributes: {}, repository: double
            )
          ).to be_a(Forms::WorkSubmissions::Core::FallbackForm)
        end

        it 'will raise an exception if neither is found' do
          expect do
            described_class.build_the_form(work: work, processing_action_name: 'missing', attributes: {}, repository: double)
          end.to raise_error(NameError)
        end
      end
    end
  end
end
