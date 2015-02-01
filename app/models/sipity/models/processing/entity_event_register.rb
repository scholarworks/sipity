module Sipity
  module Models
    module Processing
      class EntityEventRegister < ActiveRecord::Base
        self.table_name = 'sipity_processing_entity_event_registers'

        belongs_to :entity
        belongs_to :strategy_event
      end
    end
  end
end
