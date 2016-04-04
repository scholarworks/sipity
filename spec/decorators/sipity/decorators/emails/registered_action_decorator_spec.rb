require 'spec_helper'
require 'sipity/decorators/emails/registered_action_decorator'

module Sipity
  module Decorators
    module Emails
      RSpec.describe RegisteredActionDecorator do
        # This is a complicated collaboration to prepare information for an
        # email. Thus there are lots of collaborators.
        let(:requesting_user) { User.new(name: 'Hello World') }
        let(:on_behalf_of_user) { User.new(name: 'Hello World') }
        let(:work) { Models::Work.new(id: 'abc', work_type: 'doctoral_dissertation', title: 'My Title') }
        let(:requested_by_actor) { Models::Processing::Actor.new(proxy_for: requesting_user) }
        let(:on_behalf_of_actor) { Models::Processing::Actor.new(proxy_for: on_behalf_of_user) }
        let(:entity) { Models::Processing::Entity.new(proxy_for: work) }
        let(:registered_action) do
          Models::Processing::EntityActionRegister.new(
            on_behalf_of_actor: on_behalf_of_actor, requested_by_actor: requested_by_actor, entity: entity, created_at: Time.zone.now
          )
        end
        let(:repository) { QueryRepositoryInterface.new }
        subject { described_class.new(registered_action, repository: repository) }

        its(:work_type) { is_expected.to eq('Doctoral dissertation') }
        its(:title) { is_expected.to eq(work.title) }
        its(:email_message_action_description) { is_expected.to eq("Go to Doctoral dissertation “#{work.title}”") }
        its(:email_message_action_name) { is_expected.to eq("Go to Doctoral dissertation") }
        its(:email_message_action_url) { is_expected.to match(%r{/#{work.to_param}\Z}) }
        its(:action_taken_at) { is_expected.to eq registered_action.created_at }
        its(:requested_by) { is_expected.to eq requesting_user }
        its(:on_behalf_of) { is_expected.to eq on_behalf_of_user }
      end
    end
  end
end
