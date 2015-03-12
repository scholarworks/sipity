require 'spec_helper'

module Sipity
  module Decorators
    module Emails
      RSpec.describe WorkEmailDecorator do
        let(:creators) { [double(name: 'John'), double(name: 'Ringo')] }
        let(:accessible_objects) { [double(name: 'Work'), double(name: 'Attachment')] }
        let(:work) { Models::Work.new(id: 'abc', work_type: 'doctoral_dissertation', title: 'My Title') }
        let(:collaborators) { [double, double] }
        let(:reviewers) { [double, double] }
        let(:repository) { QueryRepositoryInterface.new }

        subject { described_class.new(work, repository: repository) }

        before do
          allow(repository).to receive(:scope_users_for_entity_and_roles).
            with(entity: work, roles: 'creating_user').and_return(creators)
          allow(repository).to receive(:access_rights_for_accessible_objects_of).
            with(work: work).and_return(accessible_objects)
          allow(repository).to receive(:work_collaborators_for).
            with(work: work).and_return(collaborators)
          allow(repository).to receive(:work_collaborators_responsible_for_review).
            with(work: work).and_return(reviewers)
        end

        its(:document_type) { should eq('Doctoral Dissertation') }
        its(:work_type) { should eq('Doctoral Dissertation') }
        its(:title) { should eq(work.title) }
        its(:email_message_action_description) { should eq("Review Doctoral Dissertation “#{work.title}”") }
        its(:email_message_action_name) { should eq("Review Doctoral Dissertation") }
        its(:email_message_action_url) { should match(/\/#{work.to_param}\Z/) }
        its(:email_subject) { should be_a(String) }
        its(:collaborators) { should eq(collaborators) }
        its(:reviewers) { should eq(reviewers) }

        its(:creator_names) { should eq(['John', 'Ringo']) }
        its(:review_link) { should eq(subject.email_message_action_url) }
        its(:work_show_path) { should eq(subject.email_message_action_url) }
        its(:accessible_objects) { should eq(accessible_objects) }
      end
    end
  end
end
