module Sipity
  module Models
    module Processing
      # When a given action happens for an entity, we record that
      # information here.
      #
      # In some cases, it is possible that some actions are not available to
      # take if other events have not been triggered.
      class EntityEventRegister < ActiveRecord::Base
        self.table_name = 'sipity_processing_entity_nevent_registers'

        belongs_to :entity
        belongs_to :strategy_nevent
      end
    end
  end
end
