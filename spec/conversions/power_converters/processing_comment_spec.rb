require 'rails_helper'

RSpec.describe 'PowerConverter' do
  context 'processing_comment' do
    it 'will convert a Processing Comment' do
      object = Sipity::Models::Processing::Comment.new
      expect(PowerConverter.convert(object, to: :processing_comment)).to eq(object)
    end

    it 'will convert a Processing EntityActionRegister subject' do
      object = Sipity::Models::Processing::Comment.new
      register = Sipity::Models::Processing::EntityActionRegister.new(subject: object)
      expect(PowerConverter.convert(register, to: :processing_comment)).to eq(object)
    end

    it 'will raise if Processing EntityActionRegister subject is not a comment' do
      object = Sipity::Models::Work.new
      register = Sipity::Models::Processing::EntityActionRegister.new(subject: object)
      expect { PowerConverter.convert(register, to: :processing_comment) }.
        to raise_error(PowerConverter::ConversionError)
    end

    it 'will raise to convert a string' do
      expect { PowerConverter.convert('missing', to: :processing_comment) }.
        to raise_error(PowerConverter::ConversionError)
    end
  end
end
