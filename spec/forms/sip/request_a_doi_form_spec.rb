require 'spec_helper'

module Sip
  RSpec.describe RequestADoiForm do
    let(:header) { double }
    subject { described_class.new(header: header) }

    let(:header) { double('Header') }
    let(:decorator) { double(decorate: header) }

    subject { described_class.new(decorator: decorator, header: header) }

    it 'requires a header' do
      subject = described_class.new(header: nil, decorator: nil)
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

    it 'decorates the header' do
      subject
      expect(decorator).to have_received(:decorate).with(header)
    end

    it 'has a default decorator that implements #decorate' do
      # I want the #decorator method to remain private
      # This example was to test a default path.
      expect(subject.send(:decorator)).to respond_to(:decorate)
    end
  end
end
