require 'spec_helper'

module Sipity
  module Forms
    module WorkEnrichments
      RSpec.describe CollaboratorForm do
        let(:work) { Models::Work.new(id: '1234') }
        let(:repository) { CommandRepositoryInterface.new }
        subject { described_class.new(work: work, repository: repository) }
        before do
          allow(repository).to receive(:find_or_initialize_collaborators_by).and_return(Models::Collaborator.new)
        end

        its(:policy_enforcer) { should eq Policies::Processing::WorkProcessingPolicy }

        it { should respond_to :work }
        its(:enrichment_type) { should eq('collaborator') }
        its(:collaborators) { should_not be_empty }

        it 'will require a work' do
          subject = described_class.new(work: nil, repository: repository)
          subject.valid?
          expect(subject.errors[:work]).to_not be_empty
        end

        context 'responsibility for review' do
          subject { described_class.new(work: work, collaborators_attributes: collaborators_attributes, repository: repository) }
          let(:collaborators_attributes) do
            { __sequence: { name: "Jeremy", role: "Committee Member", netid: "", email: "", responsible_for_review: "false", id: 11 } }
          end

          it 'will validate that at least one collaborator must be responsible for review' do
            expect(subject).to_not be_valid
            expect(subject.errors[:base]).to_not be_empty
          end
        end

        context 'when no collaborator attributes are passed and the form is submitted' do
          let(:collaborator) { double('Collaborator', valid?: true) }
          subject { described_class.new(work: work, repository: repository) }
          it 'will not fall back to the persisted collaborators for validation' do
            expect(work).to_not receive(:collaborators)
            expect(subject.valid?).to be_falsey
          end
        end

        context '#submit' do
          let(:user) { User.new(id: '1') }
          context 'with invalid data' do
            before do
              expect(subject).to receive(:valid?).and_return(false)
            end

            it 'will return false if not valid' do
              expect(subject.submit(requested_by: user))
            end
          end

          context 'with nested validation' do
            subject { described_class.new(work: work, collaborators_attributes: collaborators_attributes, repository: repository) }
            context 'with a missing role' do
              let(:collaborators_attributes) do
                { __sequence: { name: "Jeremy", role: "", netid: "", email: "", responsible_for_review: "false", id: 11 } }
              end
              its(:valid?) { should be_falsey }
              its(:collaborators) { should_not be_empty }
            end
            context 'with a missing name' do
              let(:collaborators_attributes) do
                { __sequence: { name: "", role: "", netid: "", email: "", responsible_for_review: "false", id: 11 } }
              end
              its(:valid?) { should be_falsey }
              its(:collaborators) { should_not be_empty }
            end
            context 'with a missing name and id' do
              let(:collaborators_attributes) do
                { __sequence: { name: "", role: "", netid: "", email: "", responsible_for_review: "0", id: '' } }
              end
              its(:valid?) { should be_falsey }
              its(:collaborators) { should_not be_empty }
            end
          end

          context 'with valid data' do
            subject { described_class.new(work: work, collaborators_attributes: collaborators_attributes, repository: repository) }
            let(:collaborators_attributes) do
              {
                __sequence: {
                  name: "Jeremy", role: "Research Director", netid: "jeremyf", email: "", responsible_for_review: "true", id: 11
                }
              }
            end

            it 'will create a collaborator' do
              expect(repository).to receive(:manage_collaborators_for).and_call_original
              subject.submit(requested_by: user)
            end
          end
        end
      end
    end
  end
end
