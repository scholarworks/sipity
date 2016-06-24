require "rails_helper"
require 'sipity/conversions/convert_to_processing_action_name'

module Sipity
  module Conversions
    describe ConvertToProcessingActionName do
      include ::Sipity::Conversions::ConvertToProcessingActionName

      context '.call' do
        it 'will call the underlying conversion method' do
          expect(described_class.call(:show)).to be_a(String)
        end
      end

      context '.convert_to_processing_action_name' do
        it 'will be private' do
          object = 1234
          expect { described_class.convert_to_processing_action_name(object) }.
            to raise_error(NoMethodError, /private method `convert_to_processing_action_name'/)
        end
      end

      context '#call' do
        it 'will not be implemented' do
          expect(self).to_not respond_to(:call)
        end
      end

      context '#convert_to_processing_action_name' do

        it 'will be a private instance method' do
          expect(self.class.private_instance_methods).to include(:convert_to_processing_action_name)
        end

        [
          [:show, 'show'],
          [:show?, 'show'],
          [:new?, 'new'],
          [:new, 'new'],
          [:create?, 'new'],
          [:create, 'new'],
          [:edit?, 'edit'],
          [:edit, 'edit'],
          [:update?, 'edit'],
          [:update, 'edit'],
          [:submit, 'submit'],
          [:submit?, 'submit'],
          [:attach, 'attach'],
          [Models::Processing::StrategyAction.new(name: 'hello'), 'hello']
        ].each_with_index do |(original, expected), index|
          it "will convert #{original.inspect} to #{expected.inspect} (scenario ##{index})" do
            expect(convert_to_processing_action_name(original)).to eq(expected)
          end
        end

        it 'will raise an exception if it is not processible' do
          object = double('Bad Wolf')
          expect { convert_to_processing_action_name(object) }.to raise_error(Exceptions::ProcessingActionNameConversionError)
        end

        it 'will leverage a short-circuit #to_processing_action_name' do
          object = double(to_processing_action_name: 'bob')
          expect(convert_to_processing_action_name(object)).to eq('bob')
        end
      end
    end
  end
end
