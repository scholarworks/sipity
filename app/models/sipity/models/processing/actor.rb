module Sipity
  module Models
    module Processing
      # A proxy for an Actor object. An Actor is someone/something that can
      # perform processes.
      #
      # A User can be an actor
      # A Group can be an actor (though a person would still need to be the
      # initiator).
      #
      # @see User
      # @see Sipity::Models::Group
      class Actor < ActiveRecord::Base
        self.table_name = 'sipity_processing_actors'

        belongs_to :proxy_for, polymorphic: true
        has_many :strategy_responsibilities, dependent: :destroy
        has_many :entity_specific_responsibilities, dependent: :destroy
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
