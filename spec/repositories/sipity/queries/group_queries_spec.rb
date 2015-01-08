require 'spec_helper'

module Sipity
  module Queries
    describe GroupQueries, type: :repository_methods do
      context '#group_names_for_entity_and_acting__As' do
        Given(:an_acting_as) { 'etd_reviewer' }
        Given(:entity) { Models::Sip.new }
        let(:actor) { Sipity::Factories.create_user(email: 'associated@hotmail.com') }

        it 'returns the group names for the given sip and acting_as' do
          Models::Permission.create!(actor: actor, acting_as: an_acting_as, entity: entity)
          expect(test_repository.group_names_for(entity: entity, acting_as: an_acting_as)).to eq(['graduate_school'])
        end

        it 'will return an empty result if there are no roles' do
          expect(test_repository.group_names_for(entity: entity, acting_as: [])).
            to eq([])
        end
      end
    end
  end
end
