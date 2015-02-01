module Sipity
  module Models
    module Processing
      class EntityPermission < ActiveRecord::Base
        self.table_name = 'sipity_processing_entity_permissions'
      end
    end
  end
end
