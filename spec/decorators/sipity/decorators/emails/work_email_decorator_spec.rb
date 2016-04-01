require 'spec_helper'
require 'sipity/decorators/emails/work_email_decorator'

module Sipity
  module Decorators
    module Emails
      RSpec.describe WorkEmailDecorator do
        let(:creators) { [double(name: 'John', username: 'john123'), double(name: 'Ringo', username: 'ringo123')] }
        let(:accessible_objects) { [double(name: 'Work'), double(name: 'Attachment')] }
        let(:work) { Models::Work.new(id: 'abc', work_type: 'doctoral_dissertation', title: 'My Title') }
        let(:collaborators) { [double, double] }
        let(:reviewers) { [double, double] }
        let(:repository) { QueryRepositoryInterface.new }
        let(:work_access) { Models::AccessRightFacade.new(work, work: work) }
        let(:program_names) { [double, double] }
        let(:degree) { [double] }
        let(:creator_netids) { ['john123', 'ringo123'] }
        let(:accessible_file) { double(name: 'Attachment') }
        let(:accessible_files) { [accessible_file] }
        let(:publishing_intent) { [double] }
        let(:patent_intent) { [double] }
        let(:submission_date) { double }
        let(:additional_attributes) do
          {
            "Sipity::Models::AdditionalAttribute::PROGRAM_NAME_PREDICATE_NAME" => program_names,
            "Sipity::Models::AdditionalAttribute::DEGREE_PREDICATE_NAME" => degree,
            "Sipity::Models::AdditionalAttribute::WORK_PUBLICATION_STRATEGY" => publishing_intent,
            "Sipity::Models::AdditionalAttribute::WORK_PATENT_STRATEGY" => patent_intent,
            "Sipity::Models::AdditionalAttribute::ETD_SUBMISSION_DATE" => submission_date
          }
        end

        subject { described_class.new(work, repository: repository) }

        before do
          allow(repository).to receive(:scope_users_for_entity_and_roles).
            with(entity: work, roles: 'creating_user').and_return(creators)
          allow(repository).to receive(:access_rights_for_accessible_objects_of).
            with(work: work, predicate_name: :all).and_return(accessible_objects)
          allow(repository).to receive(:work_collaborators_for).
            with(work: work).and_return(collaborators)
          allow(repository).to receive(:work_collaborators_responsible_for_review).
            with(work: work).and_return(reviewers)
          additional_attributes.each do |key, value|
            allow(repository).to receive(:work_attribute_values_for).
              with(work: work, key: key.constantize).
              and_return(value)
          end
        end

        its(:permanent_url) { is_expected.to be_a(String) }
        its(:work_type) { is_expected.to eq('Doctoral dissertation') }
        its(:title) { is_expected.to eq(work.title) }
        its(:email_message_action_description) { is_expected.to eq("Review Doctoral dissertation “#{work.title}”") }
        its(:email_message_action_name) { is_expected.to eq("Review Doctoral dissertation") }
        its(:email_message_action_url) { is_expected.to match(%r{/#{work.to_param}\Z}) }
        its(:collaborators) { is_expected.to eq(collaborators) }
        its(:reviewers) { is_expected.to eq(reviewers) }
        its(:creator_names) { is_expected.to eq(['John', 'Ringo']) }
        its(:accessible_objects) { is_expected.to eq(accessible_objects) }
        its(:program_names) { is_expected.to eq(program_names) }
        its(:degree) { is_expected.to eq(degree) }
        its(:creator_netids) { is_expected.to eq(creator_netids) }
        its(:publishing_intent) { is_expected.to eq(publishing_intent) }
        its(:patent_intent) { is_expected.to eq(patent_intent) }
        its(:submission_date) { is_expected.to eq(submission_date) }
        its(:catalog_system_number) do
          expect(repository).to receive(:work_attribute_values_for).with(
            work: work, key: Sipity::Models::AdditionalAttribute::CATALOG_SYSTEM_NUMBER, cardinality: 1
          ).and_return(1234)

          is_expected.to eq(1234)
        end

        its(:additional_committe_members) do
          allow(subject).to receive(:collaborators).and_return(['John', 'Ringo'])
          allow(subject).to receive(:reviewers).and_return(['Ringo'])
          additional_committe_members = ['John']
          should eq(additional_committe_members)
        end

        its(:work_access) do
          allow(Models::AccessRightFacade).to receive(:new).
            with(work, work: work).and_return(work_access)
          should eq(work_access)
        end

        its(:accessible_files) do
          allow(repository).to receive(:work_attachments).
            with(work: work, predicate_name: :all).and_return(accessible_files)
          allow(Models::AccessRightFacade).to receive(:new).
            and_return(accessible_file)
          should eq(accessible_files)
        end

      end
    end
  end
end
