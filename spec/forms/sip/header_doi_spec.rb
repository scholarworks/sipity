require 'spec_helper'

module Sip
  RSpec.describe HeaderDoi do
    it 'is not persisted' do
      expect(subject.persisted?).to eq(false)
    end

    it 'has a nil to_param' do
      expect(subject.to_param).to be_nil
    end

    it 'has an empty to_key' do
      expect(subject.to_key).to eq([])
    end

    it 'requires an identifer'
    it 'requires a header'
    it 'formats an identifier'
  end
end
