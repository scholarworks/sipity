require 'rails_helper'
require 'open_for_starting_submissions_validator'

describe OpenForStartingSubmissionsValidator do
  let(:record) { double(errors: double(add: true)) }
  let(:submission_window) { Sipity::Models::SubmissionWindow.new }
  let(:validator_parameters) { { attributes: { submission_window: submission_window } } }
  subject { OpenForStartingSubmissionsValidator.new(validator_parameters) }

  context 'validation scenarios' do
    [
      { valid?: false, open_for_starting_submissions_at: nil, closed_for_starting_submissions_at: nil },
      { valid?: false, open_for_starting_submissions_at: 2.hours.from_now, closed_for_starting_submissions_at: nil },
      { valid?: false, open_for_starting_submissions_at: 2.hours.ago, closed_for_starting_submissions_at: 2.hours.ago },
      { valid?: true, open_for_starting_submissions_at: 2.hours.ago, closed_for_starting_submissions_at: 2.hours.from_now },
      { valid?: true, open_for_starting_submissions_at: 2.hours.ago, closed_for_starting_submissions_at: nil }
    ].each_with_index do |attributes, index|
      it "will validate scenario index #{index}" do
        submission_window = Sipity::Models::SubmissionWindow.new(attributes.except(:valid?))
        expect(subject.validate_each(record, :submission_window, submission_window)).to eq(attributes.fetch(:valid?))
        if attributes.fetch(:valid?)
          expect(record.errors).to_not have_received(:add)
        else
          expect(record.errors).to have_received(:add).with(:submission_window, :invalid)
        end
      end
    end
  end
end
