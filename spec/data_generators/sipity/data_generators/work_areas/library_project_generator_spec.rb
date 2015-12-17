require 'rails_helper'
require 'sipity/data_generators/work_areas/library_project_generator'

module Sipity
  module DataGenerators
    module WorkAreas
      # Responsible for generating the submission window for the ETD work area.
      RSpec.describe LibraryProjectGenerator do
        subject { described_class }
        it 'does not deviate from the base implementation' do
          expect(subject.methods(false)).to be_empty
          expect(subject.instance_methods(false)).to be_empty
        end

        its(:constants) { should include(:SLUG) }
      end
    end
  end
end
