require 'spec_helper'
require 'sipity/decorators/emails/registered_action_decorator'

module Sipity
  module Decorators
    module Emails
      RSpec.describe RegisteredActionDecorator do
        # This is a complicated collaboration to prepare information for an
        # email. Thus there are lots of collaborators.
        let(:work) { Models::Work.new(id: 'abc', work_type: 'doctoral_dissertation', title: 'My Title') }
        let(:entity) { Models::Processing::Entity.new(proxy_for: work) }
        let(:registered_action) do
          Models::Processing::EntityActionRegister.new(
            on_behalf_of_identifier_id: 'on_behalf_of', requested_by_identifier_id: 'requested_by', entity: entity,
            created_at: Time.zone.now
          )
        end
        let(:requested_by) { double }
        let(:on_behalf_of) { double }
        let(:repository) { QueryRepositoryInterface.new }
        subject { described_class.new(registered_action, repository: repository) }

        before do
          allow(repository).to receive(:get_identifiable_agent_for).with(entity: entity, identifier_id: 'requested_by').
            and_return(requested_by)
          allow(repository).to receive(:get_identifiable_agent_for).with(entity: entity, identifier_id: 'on_behalf_of').
            and_return(on_behalf_of)
        end

        its(:default_repository) { should respond_to(:get_identifiable_agent_for) }
        its(:work_type) { should eq('Doctoral dissertation') }
        its(:title) { should eq(work.title) }
        its(:email_message_action_description) { should eq("Go to Doctoral dissertation “#{work.title}”") }
        its(:email_message_action_name) { should eq("Go to Doctoral dissertation") }
        its(:email_message_action_url) { should match(%r{/#{work.to_param}\Z}) }
        its(:action_taken_at) { should eq registered_action.created_at }
        its(:requested_by) { should eq requested_by }
        its(:on_behalf_of) { should eq on_behalf_of }
      end
    end
  end
end
