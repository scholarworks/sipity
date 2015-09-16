require 'rails_helper'
require 'sipity/data_generators/submission_windows/self_deposit_generator'
require 'sipity/data_generators/submission_windows/self_deposit_generator'

module Sipity
  module DataGenerators
    module SubmissionWindows
      # Responsible for generating the submission window for the ETD work area.
      RSpec.describe SelfDepositGenerator do
        it 'does not deviate from the base implementation' do
          expect(described_class.methods(false)).to be_empty
          expect(described_class.instance_methods(false)).to be_empty
        end
      end
    end
  end
end
