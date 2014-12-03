require 'spec_helper'

module Sip
  RSpec.describe EditHeaderForm do
    let(:header) { double('Header') }
    subject do
      described_class.new(
        header: header, exposed_attribute_names: [:title],
        attributes: { title: 'My Title', not_exposed: 'Not Exposed' }
      )
    end

    it 'will have a model_name equal to the Sip::Header' do
      expect(described_class.model_name).to eq(Sip::Header.model_name)
    end

    context 'exposing an attribute_name that is an already defined method' do
      it 'will raise an exception' do
        expect { described_class.new(header: header, exposed_attribute_names: [:submit]) }.
          to raise_error(Sip::ExistingMethodsAlreadyDefined)
      end
    end

    context 'for exposed attribute' do
      it 'will respond to that attribute name' do
        expect(subject).to respond_to(:title)
      end
      it 'will expose a getter for the attribute' do
        expect(subject.title).to eq 'My Title'
      end
      it 'will expose a getter via :send' do
        expect(subject.send(:title)).to eq('My Title')
      end
      it 'will expose the named attribute' do
        expect(subject.exposes?(:title)).to eq(true)
      end
    end

    context 'for attribute that is not exposed attribute' do
      it 'will NOT respond to that attribute name' do
        expect(subject).to_not respond_to(:not_exposed)
      end
      it 'will NOT expose a getter for the attribute' do
        expect { subject.not_exposed }.to raise_error NoMethodError
      end
      it 'will NOT expose a getter via :send' do
        expect { subject.send(:not_exposed) }.to raise_error NoMethodError
      end
      it 'will NOT expose the named attribute' do
        expect(subject.exposes?(:not_exposed)).to eq(false)
      end
    end
  end
end
