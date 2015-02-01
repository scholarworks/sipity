module Sipity
  module Models
    module Processing
      class EntityPermission < ActiveRecord::Base
        self.table_name = 'sipity_processing_entity_permissions'
        belongs_to :entity
        belongs_to :strategy_authority
      end
    end
  end
end
