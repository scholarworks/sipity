module Sipity
  module Queries
    # Queries to get group/roles related queries
    module GroupQueries
      def roles_for_entity_and_group_name(options = {})
        Models::Permission.where(options.slice(:acting_as, :entity)).pluck(:acting_as)
      end
      module_function :roles_for_entity_and_group_name
      public :roles_for_entity_and_group_name

      def group_names_for(options = {})
        roles_array = roles_for_entity_and_group_name(options)
        return [] if roles_array.empty?
        roles_array.map { |an_acting_as| Queries::PermissionQueries.permission_for(acting_as: an_acting_as) }
      end
      module_function :group_names_for
      public :group_names_for
    end
  end
end
