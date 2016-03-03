require 'rails_helper'

RSpec.describe 'PowerConverter' do
  context "work_type" do
    let(:a_work_type) { Sipity::Models::WorkType.new }
    it 'will attempt to find the given String' do
      expect(Sipity::Models::WorkType).to receive(:find_or_create_by!).with(name: 'doctoral_dissertation').and_return(a_work_type)
      expect(PowerConverter.convert('doctoral_dissertation', to: :work_type)).to eq(a_work_type)
    end

    it 'will attempt to find the given Symbol' do
      expect(Sipity::Models::WorkType).to receive(:find_or_create_by!).with(name: 'doctoral_dissertation').and_return(a_work_type)
      expect(PowerConverter.convert(:doctoral_dissertation, to: :work_type)).to eq(a_work_type)
    end

    it 'will raise an error if not found' do
      expect { PowerConverter.convert(:chicken, to: :work_type) }.
        to raise_error(PowerConverter::ConversionError)
    end

    it 'will create if we have a valid work type' do
      expect(PowerConverter.convert(:doctoral_dissertation, to: :work_type)).to be_a(Sipity::Models::WorkType)
    end

    it 'will pass through a given WorkType' do
      expect(PowerConverter.convert(a_work_type, to: :work_type)).to eq(a_work_type)
    end
  end
end
