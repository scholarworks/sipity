require 'spec_helper'

module Sipity
  module Conversions
    describe ConvertToPolymorphicType do
      include ::Sipity::Conversions::ConvertToPolymorphicType

      context '.call' do
        it 'will call the underlying conversion method' do
          object = double(to_polymorphic_type: 'Hello')
          expect(described_class.call(object)).to eq(object.to_polymorphic_type)
        end
      end

      context '.convert_to_polymorphic_type' do
        it 'will be private' do
          object = double
          expect { described_class.convert_to_polymorphic_type(object) }.
            to raise_error(NoMethodError, /private method `convert_to_polymorphic_type'/)
        end
      end

      context '#call' do
        it 'will not be implemented' do
          expect(self).to_not respond_to(:call)
        end
      end

      context '#convert_to_polymorphic_type' do
        it "will return the object to_polymorphic_type" do
          object = double(to_polymorphic_type: 'Hello')
          expect(convert_to_polymorphic_type(object)).to eq('Hello')
        end

        it "will return an ActiveRecord::Base object's base_class" do
          object = Models::Sip.new
          expect(convert_to_polymorphic_type(object)).to eq(Models::Sip)
        end

        it "will return the base class of a class that extends ActiveRecord::Base" do
          object = Models::Sip
          expect(convert_to_polymorphic_type(object)).to eq(Models::Sip)
        end

        it "will raise an error on any old object" do
          object = Object.new
          expect { convert_to_polymorphic_type(object) }.to raise_error(Exceptions::EntityTypeConversionError)
        end
      end
    end
  end
end
