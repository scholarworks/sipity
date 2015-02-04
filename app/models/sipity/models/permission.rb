require 'sipity/models'
module Sipity
  module Models
    # The given Actor has the given Role for the given Entity.
    #
    # The Role is a collection of responsibilities - actions that can be taken -
    # as enforced by a Policy object.
    #
    # The Actor is either a group or user (or perhaps an API consumer agent?).
    #
    # The Entity is the subject on which action can be taken.
    #
    # As actions are taken by a singular user, any Actor that is a group is
    # expanded to mean "each user in the group". In other words, a group Actor
    # should be thought of as short-hand for multiple Permission records; One
    # Actor for each user for the given Role and Entity.
    #
    # @note It would be possible (and may yet be implemented) to infer the Actor
    #   based on the Role and Entity's type. However, I am opting for explicit
    #   assignment of this information. I believe both explicit Role/Actor
    #   assignment and and inferred Actor from Role will be feasible in the
    #   PermissionQueries.
    #
    # @note This model is inspired by the venerable DeclarativeAuthorization gem
    #   https://github.com/stffn/declarative_authorization
    #
    # @see Sipity::Policies for more information
    # @see Sipity::Services::AuthorizationLayer
    # @see Sipity::Models::Group
    # @see Sipity::Queries::PermissionQueries
    # @see User
    # @see https://github.com/stffn/declarative_authorization
    #   DeclarativeAuthorization gem
    class Permission < ActiveRecord::Base
      CREATING_USER = 'creating_user'.freeze
      ADVISOR = 'advisor'.freeze
      self.table_name = 'sipity_permissions'
      belongs_to :actor, polymorphic: true
      belongs_to :entity, polymorphic: true
    end
  end
end
