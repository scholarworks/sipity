require 'spec_helper'

module Sipity
  module Forms
    module WorkEnrichments
      RSpec.describe CollaboratorForm do
        let(:work) { Models::Work.new(id: '1234') }
        subject { described_class.new(work: work) }

        its(:policy_enforcer) { should eq Policies::EnrichWorkByFormSubmissionPolicy }

        it { should respond_to :work }

        it 'will require a work' do
          subject = described_class.new(work: nil)
          subject.valid?
          expect(subject.errors[:work]).to_not be_empty
        end

        context '#submit' do
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double('User') }
          context 'with invalid data' do
            before do
              expect(subject).to receive(:valid?).and_return(false)
            end
            it 'will return false if not valid' do
              expect(subject.submit(repository: repository, requested_by: user))
            end
          end

          context 'with valid data' do
          end
        end
      end
    end
  end
end
