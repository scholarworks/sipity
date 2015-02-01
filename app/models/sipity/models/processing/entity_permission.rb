module Sipity
  module Models
    module Processing
      # In what capacity can an actor act upon the given entity?
      class EntityPermission < ActiveRecord::Base
        self.table_name = 'sipity_processing_entity_permissions'
        belongs_to :entity
        belongs_to :strategy_responsibility
      end
    end
  end
end
