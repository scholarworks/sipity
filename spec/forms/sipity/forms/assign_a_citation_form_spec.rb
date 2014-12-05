require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe AssignACitationForm do
      let(:header) { Models::Header.new(id: '1234') }
      subject { described_class.new(header: header) }

      it { should respond_to :header }
      it { should respond_to :citation }
      it { should respond_to :citation= }
      it { should respond_to :type }
      it { should respond_to :type= }

      it 'will require a citation' do
        subject.valid?
        expect(subject.errors[:citation]).to_not be_empty
      end

      it 'will require a header' do
        subject = described_class.new(header: nil)
        subject.valid?
        expect(subject.errors[:header]).to_not be_empty
      end

      it 'will require a type' do
        subject.valid?
        expect(subject.errors[:type]).to_not be_empty
      end
    end
  end
end
