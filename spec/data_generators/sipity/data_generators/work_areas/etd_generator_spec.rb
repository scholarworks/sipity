require 'rails_helper'
require 'sipity/data_generators/work_areas/etd_generator'

module Sipity
  module DataGenerators
    module WorkAreas
      # Responsible for generating the submission window for the ETD work area.
      RSpec.describe EtdGenerator do
        it 'does not deviate from the base implementation' do
          expect(described_class.methods(false)).to be_empty
          expect(described_class.instance_methods(false)).to be_empty
        end
      end
    end
  end
end
