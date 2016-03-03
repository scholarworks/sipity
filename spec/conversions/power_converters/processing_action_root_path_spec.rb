require 'rails_helper'

RSpec.describe 'PowerConverter' do
  context 'processing_action_root_path' do
    [
      {
        to_convert: Sipity::Models::WorkArea.new(slug: 'wa-slug'),
        expected: "/areas/wa-slug/do"
      }, {
        to_convert: Sipity::Models::SubmissionWindow.new(slug: 'sw-slug', work_area: Sipity::Models::WorkArea.new(slug: 'wa-slug')),
        expected: "/areas/wa-slug/sw-slug/do"
      }, {
        to_convert: Sipity::Models::Work.new(id: 'w-id'),
        expected: "/work_submissions/w-id/do"
      }
    ].each do |scenario|
      it "will convert #{scenario.fetch(:to_convert).inspect} to '#{scenario.fetch(:expected)}'" do
        expect(PowerConverter.convert(scenario.fetch(:to_convert), to: :processing_action_root_path)).to eq(scenario.fetch(:expected))
      end
    end

    it 'will not convert a string' do
      expect { PowerConverter.convert("Your Unconvertable", to: :processing_action_root_path) }.
        to raise_error(PowerConverter::ConversionError)
    end
  end
end
