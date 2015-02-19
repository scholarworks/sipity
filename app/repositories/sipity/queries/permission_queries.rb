module Sipity
  module Queries
    # Queries
    module PermissionQueries
      def emails_for_associated_users(acting_as:, entity:)
        # TODO: Remove the singleton query method behavior. Its ridiculous! It
        #   infects everything. This is a major code stink.
        Queries::ProcessingQueries.scope_users_for_entity_and_roles(entity: entity, roles: acting_as).pluck(:email)
      end
      module_function :emails_for_associated_users
      public :emails_for_associated_users
    end
  end
end
