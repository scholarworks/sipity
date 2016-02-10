require 'spec_helper'
require 'sipity/conversions/convert_to_processing_action'

module Sipity
  module Conversions
    describe ConvertToProcessingAction do
      include ::Sipity::Conversions::ConvertToProcessingAction

      let(:strategy_id) { 1 }
      let(:action) { Models::Processing::StrategyAction.new(id: 4, name: 'show', strategy_id: strategy_id) }

      context '.call' do
        it 'will call the underlying conversion method' do
          expect(described_class.call(action, scope: strategy_id)).to eq(action)
        end
      end

      context '.convert_to_processing_action' do
        it 'will be private' do
          object = double
          expect { described_class.convert_to_processing_action(object, scope: object) }.
            to raise_error(NoMethodError, /private method `convert_to_processing_action'/)
        end
      end

      context '#call' do
        it 'will not be implemented' do
          expect(self).to_not respond_to(:call)
        end
      end

      context '#convert_to_processing_action' do
        it 'will be a private instance method' do
          expect(self.class.private_instance_methods).to include(:convert_to_processing_action)
        end

        context "with strategy_id and action's strategy_id matching" do
          it 'will return the object if it is a Processing::StrategyAction' do
            expect(convert_to_processing_action(action, scope: strategy_id)).to eq(action)
          end

          it 'will return the object if it responds to #to_processing_action' do
            object = double(to_processing_action: action)
            expect(convert_to_processing_action(object, scope: strategy_id)).to eq(action)
          end

          it 'will raise an error if it cannot convert the object' do
            object = double
            expect { convert_to_processing_action(object, scope: strategy_id) }.
              to raise_error(Exceptions::ProcessingStrategyActionConversionError)
          end

          it 'will use a found action based on the given string and strategy_id' do
            expect(Models::Processing::StrategyAction).to receive(:find_by).and_return(action)
            expect(convert_to_processing_action(action.name, scope: strategy_id)).to eq(action)
          end

          it 'will find the action by name and strategy_id' do
            expect(Models::Processing::StrategyAction).to receive(:find_by).and_return(nil)
            expect { convert_to_processing_action(action.name, scope: strategy_id) }.
              to raise_error(Exceptions::ProcessingStrategyActionConversionError)
          end
        end
        context "with mismatching strategy_id and action's strategy_id" do
          it "will fail an error if the scope's strategy_id is different than the actions" do
            expect { convert_to_processing_action(action, scope: strategy_id + 1) }.
              to raise_error(Exceptions::ProcessingStrategyActionConversionError)
          end
        end
      end
    end
  end
end
