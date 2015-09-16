require 'spec_helper'
require 'sipity/forms/work_submissions/self_deposit/collaborator_form'

module Sipity
  module Forms
    module WorkSubmissions
      module SelfDeposit
        RSpec.describe CollaboratorForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) { {} }
          let(:user) { double }
          let(:keywords) { { work: work, repository: repository, requested_by: user, attributes: attributes } }
          subject { described_class.new(keywords) }
          before do
            allow(repository).to receive(:find_or_initialize_collaborators_by).and_return(Models::Collaborator.new)
          end

          its(:policy_enforcer) { should eq Policies::WorkPolicy }

          it { should respond_to :work }
          its(:processing_action_name) { should eq('collaborator') }
          its(:collaborators) { should_not be_empty }

          it 'will require a work' do
            subject = described_class.new(keywords.merge(work: nil))
            subject.valid?
            expect(subject.errors[:work]).to_not be_empty
          end

          context 'responsibility for review' do
            let(:attributes) do
              {
                collaborators_attributes: {
                  __sequence: { name: "Jeremy", role: "Committee Member", netid: "", email: "", id: 11 }
                }
              }
            end

            it 'will validate that at least one collaborator must be research director' do
              expect(subject).to_not be_valid
              expect(subject.errors[:base]).to_not be_empty
            end

            it 'will assign responsibility for review based on role' do
              expect(subject).to_not be_valid
              expect(subject.collaborators_from_input.first.responsible_for_review).to be_falsey
            end

          end

          context 'when no collaborator attributes are passed and the form is submitted' do
            let(:collaborator) { double('Collaborator', valid?: true) }
            subject { described_class.new(keywords) }
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
                expect(subject.submit)
              end
            end

            context 'with nested validation' do
              subject do
                described_class.new(keywords.merge(attributes: { collaborators_attributes: collaborators_attributes }))
              end
              context 'with a missing role' do
                let(:collaborators_attributes) do
                  { __sequence: { name: "Jeremy", role: "", netid: "", email: "", responsible_for_review: "false", id: 11 } }
                end
                its(:valid?) { should be_falsey }
                its(:collaborators) { should_not be_empty }
                its(:collaborators_from_input) { should_not be_empty }
              end
              context 'with a missing name' do
                let(:collaborators_attributes) do
                  { __sequence: { name: "", role: "", netid: "", email: "", responsible_for_review: "false", id: 11 } }
                end
                its(:valid?) { should be_falsey }
                its(:collaborators) { should_not be_empty }
                its(:collaborators_from_input) { should_not be_empty }
              end
              context 'with a missing name and id' do
                let(:collaborators_attributes) do
                  { __sequence: { name: "", role: "", netid: "", email: "", responsible_for_review: "0", id: '' } }
                end
                its(:valid?) { should be_falsey }
                its(:collaborators) { should_not be_empty }
                its(:collaborators_from_input) { should be_empty }
              end
              context 'with empty strings' do
                let(:collaborators_attributes) do
                  { __sequence: { name: "", role: "Research Director", netid: "jfriesen", email: "", responsible_for_review: "0" } }
                end
                it 'will nil-ify the value' do
                  expect(subject.collaborators_from_input.first.email).to be_nil
                end
              end
            end
          end
        end
      end
    end
  end
end
