module Sipity
  module Models
    # A token representation of something that could take action on Sipity.
    class Agent < ActiveRecord::Base
      self.table_name = 'sipity_agents'
      devise :token_authenticatable, :trackable
      has_one :processing_actor, as: :proxy_for, class_name: 'Sipity::Models::Processing::Actor'
    end
  end
end
