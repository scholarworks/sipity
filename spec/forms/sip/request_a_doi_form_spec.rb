require 'spec_helper'

module Sip
  RSpec.describe RequestADoiForm do
    let(:header) { double('Header') }
    subject { described_class.new(header: header) }

    it 'requires a header' do
      subject = described_class.new(header: nil)
      subject.valid?
      expect(subject.errors[:header]).to_not be_empty
    end

    it 'requires an publisher' do
      subject.valid?
      expect(subject.errors[:publisher]).to_not be_empty
    end

    it 'requires an publication_date' do
      subject.valid?
      expect(subject.errors[:publication_date]).to_not be_empty
    end
  end
end
