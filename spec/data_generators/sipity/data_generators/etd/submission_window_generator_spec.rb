require 'rails_helper'

module Sipity
  module DataGenerators
    module Etd
      # Responsible for generating the submission window for the ETD work area.
      RSpec.describe SubmissionWindowGenerator do
        let(:submission_window) { Sipity::Models::SubmissionWindow.new(id: 1, slug: 'start') }
        subject { described_class }
        xit 'will create (or reuse) the master_thesis work type' do
          subject.call(submission_window: submission_window)
        end
        xit 'will create (or reuse) the doctoral_dissertation work type' do
          subject.call(submission_window: submission_window)
        end

        it 'will grant permission to :everyone to create a master_thesis within the submission window'
        it 'will grant permission to :everyone to create a doctoral_dissertation within the submission window'
      end
    end
  end
end
