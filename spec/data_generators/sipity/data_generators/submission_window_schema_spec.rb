require 'spec_helper'
require 'sipity/data_generators/submission_window_schema'

module Sipity
  RSpec.describe DataGenerators::SubmissionWindowSchema do
    subject { described_class }

    [
      'ulra_submission_windows.config.json',
      'etd_submission_windows.config.json'
    ].each do |basename|
      it "validates #{basename}" do
        data = JSON.parse(Rails.root.join('app/data_generators/sipity/data_generators/submission_windows', basename).read)
        data.deep_symbolize_keys!
        expect(subject.call(data).messages).to be_empty
      end
    end
  end
end
