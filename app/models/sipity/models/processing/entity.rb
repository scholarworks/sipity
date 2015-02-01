module Sipity
  module Models
    module Processing
      class Entity < ActiveRecord::Base
        self.table_name = 'sipity_processing_entities'

        belongs_to :proxy_for, polymorphic: true
        belongs_to :strategy

        has_many :entity_event_registers, dependent: :destroy
        has_many :entity_permissions, dependent: :destroy
      end
    end
  end
end
