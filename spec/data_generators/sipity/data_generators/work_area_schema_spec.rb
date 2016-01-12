require 'spec_helper'

RSpec.describe Sipity::DataGenerators::WorkAreaSchema do
  subject { described_class.new }

  context 'with valid data' do
    let(:data) do
      {
        name: 'Electronic Thesis and Dissertation',
        slug: 'etd',
        actions: [
          { name: 'show', states: [{ name: 'new', roles: ['WORK_AREA_VIEWER'] }] }
        ],
        group_role_map: [
          { group: 'ALL_REGISTERED_USERS', role: 'WORK_AREA_VIEWER' }
        ]
      }
    end

    it 'validates good data' do
      expect(subject.call(data).messages).to be_empty
    end
  end

  context 'with invalid data' do
    let(:data) do
      {
        name: 'Electronic Thesis and Dissertation',
        actions: [
          { name: 'show', states: [{ name: 'new', roles: ['WORK_AREA_VIEWER'] }] }
        ],
        group_role_map: [
          { group: 'ALL_REGISTERED_USERS', role: 'WORK_AREA_VIEWER' }
        ]
      }
    end

    it 'validates good data' do
      expect(subject.call(data).messages).to eq(slug: [["slug is missing"], nil])
    end
  end
end
