module Sipity
  module Models
    # Responsible for associating a user to a group.
    #
    # @see Sipity::Models::Group
    class GroupMembership < ActiveRecord::Base
      # A privileged user of the group. They are allowed to alter membership
      # in the group. This does not bleed out into other things. That is to
      # say the ability to manage a group does not and should not infer
      # additional privleges to other policies. From the outside looking in a
      # everyone that is part of a group can fulfill the same external role.
      #
      # @see MEMBER_MEMBERSHIP_ROLE
      # @todo Codify this behavior in a policy object; But for now this is the
      #   intent
      MANAGER_MEMBERSHIP_ROLE = 'manager'.freeze

      # A member cannot alter membership of themselves or other users that are
      # part of the group.
      #
      # @see MANAGER_MEMBERSHIP_ROLE for details
      # @todo Codify this behavior in a policy object; But for now this is the
      #   intent
      MEMBER_MEMBERSHIP_ROLE = 'member'.freeze

      self.table_name = 'sipity_group_memberships'
      belongs_to :user
      belongs_to :group
      enum(
        membership_role: {
          MANAGER_MEMBERSHIP_ROLE => MANAGER_MEMBERSHIP_ROLE,
          MEMBER_MEMBERSHIP_ROLE => MEMBER_MEMBERSHIP_ROLE
        }
      )
    end
  end
end
