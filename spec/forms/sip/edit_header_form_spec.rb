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
    end

    context 'internal behaviors due to BasicObject' do
      it { expect(subject.class).to eq(EditHeaderForm) }
      it { expect(subject.inspect).to be_a(String) }
      it { expect(subject.is_a?(described_class)).to be_truthy }
      it { should respond_to :public_send }
      it { should respond_to :send }
    end
  end
end
