module Sipity
  module Models
    module Processing
      # When a given event is fired/triggered for an entity, we record that
      # information here.
      #
      # In some cases, it is possible that some events are not available to
      # take if other events have not been triggered.
      class EntityEventRegister < ActiveRecord::Base
        self.table_name = 'sipity_processing_entity_event_registers'

        belongs_to :entity
        belongs_to :strategy_event
      end
    end
  end
end
