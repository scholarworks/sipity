require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe AssignACitationForm do
      let(:work) { Models::Work.new(id: '1234') }
      subject { described_class.new(work: work) }

      it { should respond_to :work }
      it { should respond_to :citation }
      it { should respond_to :citation= }
      it { should respond_to :type }
      it { should respond_to :type= }
      its(:enrichment_type) { should be_a(String) }

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
        subject { described_class.new(work: work, type: 'ala', citation: citation) }
        context 'on invalid data' do
          let(:citation) { '' }
          let(:repository) { double }
          let(:user) { double }
          it 'returns false and does not assign a Citation' do
            expect(subject.submit(repository: repository, requested_by: user)).to eq(false)
          end
        end

        context 'on valid data' do
          let(:citation) { 'citation:abc' }
          let(:repository) { double(update_work_attribute_values!: true, log_event!: true) }
          let(:user) { User.new(id: '123') }
          it 'will assign the Citation to the work and create an event' do
            response = subject.submit(repository: repository, requested_by: user)
            expect(response).to eq(work)
          end
        end
      end
    end
  end
end
