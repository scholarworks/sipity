require 'spec_helper'

RSpec.describe Sipity::DataGenerators::WorkAreaSchema do
  subject { described_class.new }

  context 'with valid data' do
    let(:data) do
      {
        work_areas: [{
          attributes: { name: 'Electronic Thesis and Dissertation', slug: 'etd' },
          actions: [{ name: 'show', states: [{ name: 'new', roles: ['WORK_AREA_VIEWING'] }] }],
          strategy_permissions: [{ group: 'ALL_REGISTERED_USERS', role: 'WORK_AREA_VIEWING' }]
        }]
      }
    end

    it 'validates good data' do
      expect(subject.call(data).messages).to be_empty
    end
  end

  [
    "ulra_work_area.config.json",
    "etd_work_area.config.json"
  ].each do |basename|
    it "validates #{basename}" do
      data = JSON.parse(Rails.root.join('app/data_generators/sipity/data_generators/work_areas', basename).read)
      data.deep_symbolize_keys!
      expect(subject.call(data).messages).to be_empty
    end
  end

  context 'with invalid data' do
    let(:data) do
      {
        work_areas: [{
          attributes: { name: 'Electronic Thesis and Dissertation' },
          actions: [{ name: 'show', states: [{ name: 'new', roles: ['WORK_AREA_VIEWING'] }] }],
          strategy_permissions: [{ group: 'ALL_REGISTERED_USERS', role: 'WORK_AREA_VIEWING' }]
        }]
      }
    end

    it 'invalidates bad data' do
      expect(subject.call(data).messages).to be_present
    end
  end
end
