require "rails_helper"
require 'sipity/forms/work_areas'

module Sipity
  module Forms
    RSpec.describe WorkAreas do
      before do
        module WorkAreas
          module MockEtd
            class DoFunThingForm
              def initialize(**_keywords)
              end
            end
          end
        end
        module WorkAreas
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
        Forms::WorkAreas::Core.send(:remove_const, :FallbackForm)
        Forms::WorkAreas.send(:remove_const, :MockEtd)
      end

      context '#build_the_form' do
        let(:work_area) { Models::WorkArea.new(demodulized_class_prefix_name: 'MockEtd') }
        let(:processing_action_name) { 'do_fun_thing' }
        it 'will use the work area and action name to find the correct object' do
          expect(
            described_class.build_the_form(
              work_area: work_area, processing_action_name: processing_action_name, attributes: {}, repository: double
            )
          ).to be_a(Forms::WorkAreas::MockEtd::DoFunThingForm)
        end

        it 'will fall back to the core namespace' do
          expect(
            described_class.build_the_form(work_area: work_area, processing_action_name: 'fallback', attributes: {}, repository: double)
          ).to be_a(Forms::WorkAreas::Core::FallbackForm)
        end

        it 'will raise an exception if neither is found' do
          expect do
            described_class.build_the_form(work_area: work_area, processing_action_name: 'missing', attributes: {}, repository: double)
          end.to raise_error(NameError)
        end
      end
    end
  end
end
