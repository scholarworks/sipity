module Sipity
  module Queries
    # Responsible for exposing complicated queries related to Agents; Be they Collaborators or those defined in Cogitate
    module AgentQueries
      def get_identifiable_agent_for(entity:, identifier_id:, repository: self)
        identifiable_agent = begin
          repository.work_collaborators_for(work: entity, identifier_id: identifier_id).first ||
          remote_identifiable_agent_for(entity: entity, identifier_id: identifier_id) ||
          identifier_id
        end
        PowerConverter.convert(identifiable_agent, to: :identifiable_agent)
      end

      def scope_users_for_entity_and_roles(entity:, roles:)
        get_remote_identifiable_agent_finder(entity: entity).each(roles: roles).to_a
      end

      def scope_creating_users_for_entity(entity:)
        scope_users_for_entity_and_roles(entity: entity, roles: Models::Role::CREATING_USER)
      end

      # @api public
      #
      # @param entity [#to_processing_entity]
      # @return Hash keyed by role names with values of email addresses.
      def get_role_names_with_email_addresses_for(entity:)
        get_remote_identifiable_agent_finder(entity: entity).role_names_with_emails
      end

      private

      def remote_identifiable_agent_for(entity:, identifier_id:)
        get_remote_identifiable_agent_finder(entity: entity).detect { |agent| agent.ids.include?(identifier_id) }
      end

      def get_remote_identifiable_agent_finder(entity:)
        # Because not all entity objects are the same thing.
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        @remote_identiable_agent_finder_cache ||= {}
        @remote_identiable_agent_finder_cache[entity.id] ||= Queries::Complex::AgentsAssociatedWithEntity.new(entity: entity)
      end
    end
  end
end
