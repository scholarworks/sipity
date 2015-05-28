module Sipity
  module Models
    module Processing
      # When a given action happens for an entity, we record that
      # information here.
      #
      # In some cases, it is possible that some actions are not available to
      # take if other events have not been triggered.
      class EntityActionRegister < ActiveRecord::Base
        self.table_name = 'sipity_processing_entity_action_registers'

        belongs_to :entity
        belongs_to :strategy_action
        belongs_to :requested_by_actor, class_name: 'Sipity::Models::Processing::Actor'
        belongs_to :on_behalf_of_actor, class_name: 'Sipity::Models::Processing::Actor'
        belongs_to :subject, polymorphic: true

        # Lazy validation. All objects going forward will require this. And I'll
        # move that requirement into the database after we have a migration.
        validates :subject_id, presence: true
        validates :subject_type, presence: true

        alias_method :to_processing_action, :strategy_action
        alias_method :to_processing_entity, :entity
        delegate :proxy_for, to: :entity
      end
    end
  end
end
