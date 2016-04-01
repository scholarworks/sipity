require 'spec_helper'
require 'sipity/processing_hooks'

module Sipity
  # A container module for functions that are called as part of
  # a Processing action being taken.
  RSpec.describe ProcessingHooks do
    let(:call_parameter_interface) { [[:keyreq, :action], [:keyreq, :entity], [:keyreq, :requested_by], [:keyrest, :keywords]] }

    context '.call' do
      it 'will implement a specific parameter interface' do
        expect(described_class.method(:call).parameters).to eq(call_parameter_interface)
      end
      before do
        module ProcessingHooks
          module Mock
            module WorkAreas
              module HelloProcessingHook
                module_function

                def call(**__keywords)
                end
              end
            end
          end
        end
      end

      after do
        described_class.send(:remove_const, :Mock)
      end

      subject { described_class }
      let(:action) { Models::Processing::StrategyAction.new(id: 3, strategy_id: entity.strategy_id, name: 'hello') }
      let(:entity) { Models::Processing::Entity.new(id: 2, strategy_id: 1, proxy_for: work_area) }
      let(:actor) { Models::Processing::Actor.new(id: 1) }
      let(:work_area) { Models::WorkArea.new(demodulized_class_prefix_name: 'Mock') }

      it 'will attempt to find the corresponding module to call based on the action' do
        expect(described_class::Mock::WorkAreas::HelloProcessingHook).to receive(:call).and_call_original
        subject.call(action: action, entity: entity, requested_by: actor)
      end

      it 'will leverage the fallback hook' do
        action = Models::Processing::StrategyAction.new(id: 3, strategy_id: entity.strategy_id, name: 'good_bye')
        fallback_hook = double(call: true)
        keywords = { action: action, entity: entity, requested_by: actor, fallback_hook: fallback_hook, bogus_karg: 'bogus' }
        subject.call(keywords)
        expect(fallback_hook).to have_received(:call).with(keywords)
      end

      its(:default_fallback_hook) { is_expected.to respond_to(:call) }
    end
  end
end
