require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe CreateOrcidAccountPlaceholderForm do
      subject { described_class.new(identifier: '0000-0002-8205-121X', name: 'Hello') }

      it { should respond_to :identifier }
      it { should respond_to :identifier= }
      it { should respond_to :name }
      it { should respond_to :name= }

      it 'will require an identifier' do
        subject.identifier = nil
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

      Given(:user) { User.new(id: 1) }
      Given(:repository) { CommandRepositoryInterface.new }
      context 'with invalid data' do
        before { allow(subject).to receive(:valid?).and_return(false) }
        When(:response) { subject.submit(requested_by: user, repository: repository) }
        Then { response == false }
      end
      context 'with valid data' do
        When(:model) { subject.submit(requested_by: user, repository: repository) }
        Then { model.persisted? }
        And { model.is_a?(Models::AccountPlaceholder) }
      end
    end
  end
end
