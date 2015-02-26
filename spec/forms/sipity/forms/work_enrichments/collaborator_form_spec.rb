require 'spec_helper'

module Sipity
  module Forms
    module WorkEnrichments
      RSpec.describe CollaboratorForm do
        let(:work) { Models::Work.new(id: '1234') }
        subject { described_class.new(work: work) }

        its(:policy_enforcer) { should eq Policies::Processing::WorkProcessingPolicy }

        it { should respond_to :work }
        its(:enrichment_type) { should eq('collaborator') }
        its(:collaborators) { should_not be_empty }

        it 'will require a work' do
          subject = described_class.new(work: nil)
          subject.valid?
          expect(subject.errors[:work]).to_not be_empty
        end

        context 'responsibility for review' do
          subject { described_class.new(work: work, collaborators_attributes: collaborators_attributes) }
          let(:collaborators_attributes) do
            { __sequence: { name: "Jeremy", role: "author", netid: "", email: "", responsible_for_review: "false", id: 11 } }
          end

          it 'will validate that at least one collaborator must be responsible for review' do
            expect(subject).to_not be_valid
            expect(subject.errors[:base]).to_not be_empty
          end
        end

        context '#submit' do
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { User.new(id: '1') }
          context 'with invalid data' do
            before do
              expect(subject).to receive(:valid?).and_return(false)
            end

            it 'will return false if not valid' do
              expect(subject.submit(repository: repository, requested_by: user))
            end
          end

          context 'with nested validation' do
            subject { described_class.new(work: work, collaborators_attributes: collaborators_attributes) }
            let(:collaborators_attributes) do
              # Because the role is empty!----------V
              { __sequence: { name: "Jeremy", role: "", netid: "", email: "", responsible_for_review: "false", id: 11 } }
            end
            its(:valid?) { should be_falsey }
          end

          context 'with valid data' do
            subject { described_class.new(work: work, collaborators_attributes: collaborators_attributes) }
            let(:collaborators_attributes) do
              { __sequence: { name: "Jeremy", role: "author", netid: "jeremyf", email: "", responsible_for_review: "true", id: 11 } }
            end

            it 'will create a collaborator' do
              expect(Queries::CollaboratorQueries).to receive(:find_or_initialize_collaborators_by).and_call_original
              expect(repository).to receive(:assign_collaborators_to).and_call_original
              subject.submit(repository: repository, requested_by: user)
            end
          end
        end
      end
    end
  end
end
