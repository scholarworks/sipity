require 'spec_helper'

module Sipity
  module Queries
    # Queries
    RSpec.describe ProcessingQueries, type: :isolated_repository_module do
      context '#available_processing_events_for' do

      end

      context '#scope_for_processing_actors_from_user' do
        let(:user) { User.new(id: 1) }
        let(:group) { Models::Group.new(id: 1) }
        let!(:user_processing_actor) do
          Models::Processing::Actor.create(proxy_for_id: user.id, proxy_for_type: Conversions::ConvertToPolymorphicType.call(user))
        end
        let!(:group_processing_actor) do
          Models::Processing::Actor.create(proxy_for_id: group.id, proxy_for_type: Conversions::ConvertToPolymorphicType.call(group))
        end
        before { Models::GroupMembership.create(user_id: user.id, group_id: group.id) }

        it 'will return an array of both user ' do
          expect(test_repository.scope_for_processing_actors_from_user(user: user)).
            to eq([user_processing_actor, group_processing_actor])
        end
      end
    end
  end
end
