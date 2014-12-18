module Sipity
  module Models
    class GroupMembership < ActiveRecord::Base
      self.table_name = 'sipity_group_memberships'
      belongs_to :user
      belongs_to :group
      enum(
        membership_role: {
          'manager' => 'manager',
          'member' => 'member'
        }
      )
    end
  end
end
