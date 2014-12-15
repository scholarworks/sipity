require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe CreateOrcidAccountPlaceholderForm do
      subject { described_class.new }

      it { should respond_to :identifier }
      it { should respond_to :identifier= }
      it { should respond_to :name }
      it { should respond_to :name= }

      it 'will require an identifier' do
        subject.valid?
        expect(subject.errors[:identifier]).to_not be_empty
      end

      it 'will require valid formating for an ORCID identifier' do
        subject.identifier = 'ABCD'
        subject.valid?
        expect(subject.errors[:identifier]).to_not be_empty
      end

      it 'will validate when given an ORCID identifier that is "correct"' do
        subject.identifier = '0000-0002-8205-121X'
        expect(subject).to be_valid
      end
    end
  end
end
