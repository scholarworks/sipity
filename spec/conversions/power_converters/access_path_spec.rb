require 'rails_helper'

RSpec.describe 'PowerConverter' do
  context 'access_path' do
    [
      {
        to_convert: Sipity::Models::WorkArea.new(slug: 'wa-slug'),
        expected: "/areas/wa-slug"
      }, {
        to_convert: Sipity::Models::SubmissionWindow.new(slug: 'sw-slug', work_area: Sipity::Models::WorkArea.new(slug: 'wa-slug')),
        expected: "/areas/wa-slug/sw-slug"
      }, {
        to_convert: Sipity::Models::Work.new(id: 'w-id'),
        expected: "/work_submissions/w-id"
      }
    ].each do |scenario|
      it "will convert #{scenario.fetch(:to_convert).inspect} to '#{scenario.fetch(:expected)}'" do
        expect(PowerConverter.convert(scenario.fetch(:to_convert), to: :access_url)).to match(scenario.fetch(:expected))
      end
    end

    it 'will not convert an attachment' do
      object = Sipity::Models::Attachment.create!(file: File.new(__FILE__), work_id: 1, pid: 2, predicate_name: 'attachment')
      expect { PowerConverter.convert(object, to: :access_path) }.
        to raise_error(PowerConverter::ConversionError)
    end
  end
end
