require 'rails_helper'

RSpec.describe 'PowerConverter' do
  context 'submission_window' do
    it "will convert based on the given scenarios" do

      work_area = Sipity::Models::WorkArea.new(id: 1)
      submission_window = Sipity::Models::SubmissionWindow.new(id: 2, slug: 'slug', work_area_id: work_area.id)
      expect(PowerConverter.convert(submission_window, to: :submission_window, scope: work_area)).to eq(submission_window)

      # Without scope as a consideration
      expect(PowerConverter.convert(submission_window, to: :submission_window)).to eq(submission_window)

      work = Sipity::Models::Work.new(id: 8)
      allow(work).to receive(:submission_window).and_return(submission_window)
      expect(PowerConverter.convert(work, to: :submission_window)).to eq(submission_window)

      expect { PowerConverter.convert(submission_window, to: :submission_window, scope: Sipity::Models::WorkArea.new(id: 822)) }.
        to raise_error(PowerConverter::ConversionError)
    end
  end
end
