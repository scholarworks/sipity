module Sipity
  module Models
    class GroupMembership < ActiveRecord::Base
      self.table_name = 'sipity_group_memberships'
      belongs_to :user
      belongs_to :group
    end
  end
end
