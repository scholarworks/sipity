module Sipity
  module Models
    module Processing
      class Strategy < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategies'
      end
    end
  end
end
