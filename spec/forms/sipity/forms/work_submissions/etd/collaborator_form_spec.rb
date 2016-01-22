require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/etd/collaborator_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
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
          its(:possible_roles) { should be_a(Hash) }

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

            it 'will be invalid if none of the collaborators is a research director' do
              expect(subject).to_not be_valid
              expect(subject.errors[:base]).to_not be_empty
            end

            it 'will be valid if one of the collaborators is a research director with netid' do
              attributes = {
                collaborators_attributes: {
                  __sequence: { name: "Jeremy", role: Models::Collaborator::RESEARCH_DIRECTOR_ROLE, netid: "a_net_id", email: "", id: 11 }
                }
              }
              subject = described_class.new(keywords.merge(attributes: attributes))
              expect(subject).to be_valid
              expect(subject.errors[:base]).to be_empty
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

              context 'with missing netid' do
                let(:collaborators_attributes) do
                  { __sequence: { name: "", role: "Research Director", netid: "", email: "test@test.com", responsible_for_review: "0" } }
                end
                its(:valid?) { should be_falsey }
                its(:collaborators) { should_not be_empty }
                its(:collaborators_from_input) { should_not be_empty }
              end
            end

            context 'with valid data' do
              let(:attributes) do
                {
                  collaborators_attributes: {
                    __sequence: {
                      name: "Jeremy", role: "Research Director", netid: "jeremyf", email: "", responsible_for_review: "true", id: 11
                    }
                  }
                }
              end

              it 'will create a collaborator' do
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
                expect(repository).to receive(:manage_collaborators_for).
                  with(work: work, collaborators: subject.collaborators_from_input).
                  and_call_original
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
