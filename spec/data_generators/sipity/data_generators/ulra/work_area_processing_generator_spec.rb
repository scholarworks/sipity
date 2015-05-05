require 'rails_helper'
require 'sipity/data_generators/ulra/work_area_processing_generator'

module Sipity
  module DataGenerators
    module Ulra
      # Responsible for generating the submission window for the ETD work area.
      RSpec.describe WorkAreaProcessingGenerator do
        it 'does not deviate from the base implementation' do
          expect(described_class.methods(false)).to be_empty
          expect(described_class.instance_methods(false)).to be_empty
        end
      end
    end
  end
end
