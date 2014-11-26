require 'spec_helper'

module Sip
  RSpec.describe AssignADoiForm do
    let(:header) { double('Header') }
    let(:decorator) { double(decorate: header) }

    subject { described_class.new(decorator: decorator, header: header) }

    it 'requires a header' do
      subject = described_class.new(header: nil, decorator: nil)
      subject.valid?
      expect(subject.errors[:header]).to_not be_empty
    end

    it 'requires an identifer' do
      subject.valid?
      expect(subject.errors[:identifier]).to_not be_empty
    end

    its(:identifier_key) { should be_a(String) }

    it 'formats an identifier'

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
