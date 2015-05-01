require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe WorkAreaForms do
      before do
        module WorkAreaForms
          module MockEtd
            class DoFunThingForm
              def initialize(**_keywords)
              end
            end
          end
        end
      end
      after do
        WorkAreaForms.send(:remove_const, :MockEtd)
      end

      context '#build_the_form' do
        let(:work_area) { Models::WorkArea.new(demodulized_class_prefix_name: 'MockEtd') }
        let(:processing_action_name) { 'do_fun_thing' }
        it 'will use the work area and action name to find the correct object' do
          expect(described_class.build_the_form(work_area: work_area, processing_action_name: processing_action_name, attributes: {})).
            to be_a(WorkAreaForms::MockEtd::DoFunThingForm)
        end
      end
    end
  end
end
