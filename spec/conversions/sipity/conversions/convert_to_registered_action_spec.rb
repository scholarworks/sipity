require "rails_helper"
require 'sipity/conversions/convert_to_registered_action'

module Sipity
  module Conversions
    describe ConvertToRegisteredAction do
      include ::Sipity::Conversions::ConvertToRegisteredAction
      let(:resulting_object) { Models::Processing::EntityActionRegister.new }

      context '.call' do
        it 'will call the underlying conversion method' do
          expect(described_class.call(resulting_object)).to eq(resulting_object)
        end
      end

      context '.convert_to_registered_action' do
        it 'will be private' do
          expect { described_class.convert_to_registered_action(resulting_object) }.
            to raise_error(NoMethodError, /private method `convert_to_registered_action'/)
        end
      end

      context '#call' do
        it 'will not be implemented' do
          expect(self).to_not respond_to(:call)
        end
      end

      context '#convert_to_registered_action' do
        it 'will be a private instance method' do
          expect(self.class.private_instance_methods).to include(:convert_to_registered_action)
        end

        it 'will return the object if it is a Models::Processing::EntityActionRegister' do
          expect(convert_to_registered_action(resulting_object)).to eq(resulting_object)
        end

        it 'will return the object there is a #to_registered_action method' do
          proxy = double(to_registered_action: resulting_object)
          expect(convert_to_registered_action(proxy)).to eq(resulting_object)
        end

        it 'will raise an error if it cannot convert' do
          object = double
          expect { convert_to_registered_action(object) }.to raise_error(Exceptions::RegisteredActionConversionError)
        end
      end
    end
  end
end
