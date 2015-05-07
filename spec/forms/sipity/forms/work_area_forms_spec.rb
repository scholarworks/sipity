require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe WorkAreaForms do
      before do
        module MockEtd
          module WorkAreas
            class DoFunThingForm
              def initialize(**_keywords)
              end
            end
          end
        end
        module Core
          module WorkAreas
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
        Forms::Core::WorkAreas.send(:remove_const, :FallbackForm)
      end

      context '#build_the_form' do
        let(:work_area) { Models::WorkArea.new(demodulized_class_prefix_name: 'MockEtd') }
        let(:processing_action_name) { 'do_fun_thing' }
        it 'will use the work area and action name to find the correct object' do
          expect(described_class.build_the_form(work_area: work_area, processing_action_name: processing_action_name, attributes: {})).
            to be_a(Forms::MockEtd::WorkAreas::DoFunThingForm)
        end

        it 'will fall back to the core namespace' do
          expect(described_class.build_the_form(work_area: work_area, processing_action_name: 'fallback', attributes: {})).
            to be_a(Forms::Core::WorkAreas::FallbackForm)
        end

        it 'will raise an exception if neither is found' do
          expect { described_class.build_the_form(work_area: work_area, processing_action_name: 'missing', attributes: {}) }.
            to raise_error(NameError)
        end
      end
    end
  end
end
