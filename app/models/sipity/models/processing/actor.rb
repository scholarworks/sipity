module Sipity
  module Models
    module Processing
      class Actor < ActiveRecord::Base
        self.table_name = 'sipity_processing_actors'

        belongs_to :proxy_for, polymorphic: true
        has_many :strategy_authorities, dependent: :destroy
      end
    end
  end
end
