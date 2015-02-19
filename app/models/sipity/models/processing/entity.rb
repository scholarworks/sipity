module Sipity
  module Models
    module Processing
      # A proxy for the entity that is being processed.
      # By using a proxy, we need not worry about polluting the proxy's concerns
      # with things related to processing.
      #
      # The goal is to keep this behavior separate, so that we can possibly
      # extract the information.
      class Entity < ActiveRecord::Base
        self.table_name = 'sipity_processing_entities'

        belongs_to :proxy_for, polymorphic: true
        belongs_to :strategy
        belongs_to :strategy_state

        has_many :entity_action_registers, dependent: :destroy
        has_many :entity_specific_responsibilities, dependent: :destroy

        delegate :name, to: :strategy_state, prefix: :strategy_state
        # TODO: This is a concession for the existing application
        alias_method :processing_state, :strategy_state_name
      end
    end
  end
end
