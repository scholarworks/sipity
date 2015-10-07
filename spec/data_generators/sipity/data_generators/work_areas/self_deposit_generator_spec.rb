require 'rails_helper'
require 'sipity/data_generators/work_areas/self_deposit_generator'
require 'sipity/data_generators/work_areas/self_deposit_generator'

module Sipity
  module DataGenerators
    module WorkAreas
      RSpec.describe SelfDepositGenerator do
        it 'does not deviate from the base implementation' do
          expect(described_class.methods(false)).to be_empty
          expect(described_class.instance_methods(false)).to be_empty
        end

        it 'has a slug that converts to a slug via PowerConverter' do
          actual = described_class::SLUG
          expected = PowerConverter.convert_to_slug(described_class::SLUG)
          expect(expected).to eq(actual)
        end
      end
    end
  end
end
