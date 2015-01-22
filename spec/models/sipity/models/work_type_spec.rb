require 'rails_helper'

module Sipity
  module Models
    RSpec.describe WorkType, type: :model do
      context '.[]' do
        it 'will have an ETD' do
          expect(described_class['etd']).to be_a(WorkType)
        end

        it 'will raise an exception if the WorkType is invalid' do
          expect { described_class['__MISSIN__'] }.to raise_error(Exceptions::WorkTypeNotFoundError)
        end
      end

      context '.all_for_enum_configuration' do
        it 'will be a Hash to appease the enum interface' do
          expect(described_class.all_for_enum_configuration).to be_a(Hash)
        end
      end
    end
  end
end
