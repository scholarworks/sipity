module Sipity
  module Models
    module Processing
      class Actor < ActiveRecord::Base
        self.table_name = 'sipity_processing_actors'
      end
    end
  end
end
