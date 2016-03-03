require 'rails_helper'

RSpec.describe 'PowerConverter' do
  context 'role' do
    it "will convert Sipity::Models::Role" do
      object = Sipity::Models::Role.new
      expect(PowerConverter.convert(object, to: :role)).to eq(object)
    end

    it "will convert a #to_role object" do
      object = double(to_role: Sipity::Models::Role.new)
      expect(PowerConverter.convert(object, to: :role)).to eq(object.to_role)
    end

    it "will convert a valid string" do
      object = Sipity::Models::Role::CREATING_USER
      expect(PowerConverter.convert(object, to: :role)).to be_a(Sipity::Models::Role)
    end

    it "will convert a base object with composed attributes delegator" do
      base_object = Sipity::Models::Role.new
      object = Sipity::Decorators::BaseObjectWithComposedAttributesDelegator.new(base_object)
      expect(PowerConverter.convert(object, to: :role)).to eq(base_object)
    end

    it 'will not convert a string' do
      expect { PowerConverter.convert("Your Unconvertable", to: :role) }.
        to raise_error(PowerConverter::ConversionError)
    end
  end
end
