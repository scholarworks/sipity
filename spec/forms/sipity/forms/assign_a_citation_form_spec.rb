require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe AssignACitationForm do
      let(:repository) { CommandRepositoryInterface.new }
      let(:work) { Models::Work.new(id: '1234') }
      subject { described_class.new(work: work, repository: repository) }

      it { should respond_to :work }
      it { should respond_to :citation }
      it { should respond_to :type }
      its(:enrichment_type) { should be_a(String) }
      it { should respond_to(:to_processing_entity) }

      it 'will require a citation' do
        subject.valid?
        expect(subject.errors[:citation]).to_not be_empty
      end

      it 'will require a work' do
        subject = described_class.new(work: nil)
        subject.valid?
        expect(subject.errors[:work]).to_not be_empty
      end

      it 'will require a type' do
        subject.valid?
        expect(subject.errors[:type]).to_not be_empty
      end

      context 'submit' do
        subject { described_class.new(work: work, type: 'ala', citation: citation, repository: repository) }
        context 'on invalid data' do
          let(:citation) { '' }
          let(:user) { double }
          it 'returns false and does not assign a Citation' do
            expect(subject.submit(requested_by: user)).to eq(false)
          end
        end

        context 'on valid data' do
          let(:citation) { 'citation:abc' }
          let(:user) { User.new(id: '123') }
          it 'will assign the the work and create an event' do
            expect(repository).to receive(:log_event!).and_call_original
            expect(repository).to receive(:update_work_attribute_values!).twice.and_call_original
            response = subject.submit(requested_by: user)
            expect(response).to eq(work)
          end
        end
      end
    end
  end
end
