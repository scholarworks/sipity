require 'spec_helper'

module Sipity
  module Queries
    # Queries
    RSpec.describe PermissionQueries, type: :isolated_repository_module do
      context 'querying for augmented permission records' do
        let(:entity) { Models::Work.new(id: 1, work_type: 'etd', processing_state: 'new') }
        let(:user) { User.new(id: 2) }
        let(:group) { Models::Group.new(id: 3) }
        let(:direct_user_permission) do
          Models::Permission.new(
            actor_id: user.id, actor_type: user.class.base_class, acting_as: 'as_a_user',
            entity_id: entity.id, entity_type: entity.class.base_class
          )
        end
        let(:indirect_user_permission) do
          Models::Permission.new(
            actor_id: group.id, actor_type: group.class.base_class, acting_as: 'as_a_group',
            entity_id: entity.id, entity_type: entity.class.base_class
          )
        end
        before do
          Models::GroupMembership.create!(group_id: group.id, user_id: user.id)
        end
      end
    end
  end
end
