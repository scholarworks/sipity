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
    end
  end
end
