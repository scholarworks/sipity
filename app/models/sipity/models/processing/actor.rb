module Sipity
  module Models
    module Processing
      # A proxy for something that can take an action.
      #
      # * A User can be an actor
      # * A Group can be an actor (though a person would still need to be the
      #   initiator?).
      #
      # @see User
      # @see Sipity::Models::Group
      # @see Sipity::Queries::ProcessingQueries#scope_users_for_entity_and_roles
      class Actor < ActiveRecord::Base
        self.table_name = 'sipity_processing_actors'

        ENTITY_LEVEL_ACTOR_PROCESSING_RELATIONSHIP = 'entity_level'.freeze
        STRATEGY_LEVEL_ACTOR_PROCESSING_RELATIONSHIP = 'strategy_level'.freeze

        belongs_to :proxy_for, polymorphic: true
        has_many :strategy_responsibilities, dependent: :destroy
        has_many :entity_specific_responsibilities, dependent: :destroy
        has_many(
          :processing_comments,
          foreign_key: :actor_id,
          dependent: :destroy,
          class_name: 'Sipity::Models::Processing::Comment'
        )
        has_many(
          :actions_that_were_requested_by_me,
          dependent: :destroy,
          foreign_key: 'requested_by_actor_id',
          class_name: "Sipity::Models::Processing::EntityActionRegister"
        )
        has_many(
          :actions_that_an_actor_took_on_my_behalf,
          dependent: :destroy,
          foreign_key: 'on_behalf_of_actor_id',
          class_name: "Sipity::Models::Processing::EntityActionRegister"
        )
      end
    end
  end
end
