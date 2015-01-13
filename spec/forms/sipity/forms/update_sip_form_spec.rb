require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe UpdateSipForm do
      let(:work) { double('Sip') }
      subject do
        described_class.new(
          work: work, exposed_attribute_names: [:title],
          attributes: { title: 'My Title', not_exposed: 'Not Exposed' }
        )
      end

      its(:policy_enforcer) { should eq Policies::EnrichSipByFormSubmissionPolicy }
      its(:to_model) { should eq(work) }

      it 'will have a model_name that is the same as the Models::Work.model_name' do
        expect(described_class.model_name).to eq(Models::Work.model_name)
      end

      context 'exposing an attribute_name that is an already defined method' do
        it 'will raise an exception' do
          expect { described_class.new(work: work, exposed_attribute_names: [:submit]) }.
            to raise_error(Exceptions::ExistingMethodsAlreadyDefined)
        end
      end

      context 'when no attribute_names are exposed' do
        it 'will NOT raise an exception' do
          expect { described_class.new(work: work, exposed_attribute_names: []) }.
            to_not raise_error
        end
      end

      context 'for an exposed attribute' do
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

      context 'for an attribute that is not an exposed attribute' do
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
end
