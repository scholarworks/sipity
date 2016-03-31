require 'spec_helper'
require 'sipity/conversions/to_rof/work_converters/ulra_converters'

module Sipity
  module Conversions
    module ToRof
      module WorkConverters
        RSpec.describe UlraSeniorThesisConverter do
          let(:work) do
            Models::Work.new(id: 'abcd-ef', access_right: access_right, created_at: Time.zone.today)
          end
          let(:access_right) { Models::AccessRight.new(access_right_code: Models::AccessRight::OPEN_ACCESS) }
          let(:collaborator) { Models::Collaborator.new(role: Models::Collaborator::ADVISING_FACULTY_ROLE, name: 'Alexander Hamilton') }
          let(:repository) { QueryRepositoryInterface.new }
          subject { described_class.new(work: work, repository: repository) }

          its(:af_model) { is_expected.to eq('SeniorThesis') }
          its(:to_hash) { is_expected.to be_a(Hash) }
          its(:metadata) { is_expected.to be_a(Hash) }
          its(:rels_ext) { is_expected.to be_a(Hash) }

          its(:advising_faculty) do
            expect(repository).to(
              receive(:work_collaborator_names_for).with(work: work, role: Models::Collaborator::ADVISING_FACULTY_ROLE).and_return('Bob')
            )
            is_expected.to be_a(Array)
          end

          context 'ATTACHMENT_TYPES_FOR_EXPORT' do
            subject { described_class::ATTACHMENT_TYPES_FOR_EXPORT }
            it { is_expected.to be_a(Array) }
            it { is_expected.to_not include('faculty_letter_of_recommendation') }
          end

          context '#attachments' do
            it 'should retrieve all attachments' do
              expect(repository).to receive(:work_attachments).with(
                work: work, predicate_name: described_class::ATTACHMENT_TYPES_FOR_EXPORT
              ).and_return(:returned_value)
              expect(subject.attachments).to be_a(Array)
            end
          end

          its(:creator_names) do
            expect(repository).to(
              receive(:scope_users_for_entity_and_roles).with(
                entity: work, roles: Models::Role::CREATING_USER
              ).and_return(double(name: 'Bob'))
            )
            is_expected.to be_a(Array)
          end
        end
        RSpec.describe UlraDocumentConverter do
          let(:work) do
            Models::Work.new(id: 'abcd-ef', access_right: access_right, created_at: Time.zone.today)
          end
          let(:access_right) { Models::AccessRight.new(access_right_code: Models::AccessRight::OPEN_ACCESS) }
          let(:collaborator) { Models::Collaborator.new(role: Models::Collaborator::ADVISING_FACULTY_ROLE, name: 'Alexander Hamilton') }
          let(:repository) { QueryRepositoryInterface.new }
          subject { described_class.new(work: work, repository: repository) }

          its(:af_model) { is_expected.to eq('Document') }
          its(:to_hash) { is_expected.to be_a(Hash) }
          its(:metadata) { is_expected.to be_a(Hash) }
          its(:rels_ext) { is_expected.to be_a(Hash) }

          its(:advising_faculty) do
            expect(repository).to(
              receive(:work_collaborator_names_for).with(work: work, role: Models::Collaborator::ADVISING_FACULTY_ROLE).and_return('Bob')
            )
            is_expected.to be_a(Array)
          end

          context '#attachments' do
            it 'should retrieve all attachments' do
              expect(repository).to receive(:work_attachments).with(
                work: work, predicate_name: described_class::ATTACHMENT_TYPES_FOR_EXPORT
              ).and_return(:returned_value)
              expect(subject.attachments).to be_a(Array)
            end
          end

          its(:creator_names) do
            expect(repository).to(
              receive(:scope_users_for_entity_and_roles).with(
                entity: work, roles: Models::Role::CREATING_USER
              ).and_return(double(name: 'Bob'))
            )
            is_expected.to be_a(Array)
          end
        end
      end
    end
  end
end
