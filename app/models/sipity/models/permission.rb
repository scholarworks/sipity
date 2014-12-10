require 'sipity/models'
module Sipity
  module Models
    # Sits between a user and an entity defining the role for access.
    class Permission < ActiveRecord::Base
      CREATING_USER = 'creating_user'.freeze
      self.table_name = 'sipity_permissions'
      belongs_to :user
      belongs_to :entity, polymorphic: true
    end
  end
end
