require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe AttachFilesToWorkForm do
      let(:work) { Models::Work.new(id: '1234') }
      subject { described_class.new(work: work) }

      its(:policy_enforcer) { should be_present }

      context 'validations' do
        it 'will require a work' do
          subject = described_class.new(work: nil)
          subject.valid?
          expect(subject.errors[:work]).to_not be_empty
        end
        it 'will require at least one file' do
          subject = described_class.new(files: [], work: work)
          subject.valid?
          expect(subject.errors[:files]).to_not be_empty
        end
      end
    end
  end
end
