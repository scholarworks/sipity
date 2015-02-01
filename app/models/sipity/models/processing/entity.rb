module Sipity
  module Models
    module Processing
      class Entity < ActiveRecord::Base
        self.table_name = 'sipity_processing_entities'
      end
    end
  end
end
