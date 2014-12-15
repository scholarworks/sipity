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
    end
  end
end
