module Sipity
  module Models
    module Processing
      class EntityEventRegister < ActiveRecord::Base
        self.table_name = 'sipity_processing_entity_event_registers'
      end
    end
  end
end
