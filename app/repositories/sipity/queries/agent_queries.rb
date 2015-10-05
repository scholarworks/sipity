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

      def scope_creating_users_for_entity(entity:, roles: Models::Role::CREATING_USER)
        get_remote_identifiable_agent_finder(entity: entity).each(roles: roles)
      end

      # @api public
      #
      # @param entity [#to_processing_entity]
      # @return Hash keyed by role names with values of email addresses.
      def get_role_names_with_email_addresses_for(entity:)
        Queries::Complex::AgentsAssociatedWithEntity.role_names_with_emails_for(entity: entity)
      end

      private

      def remote_identifiable_agent_for(entity:, identifier_id:)
        get_remote_identifiable_agent_finder(entity: entity).detect { |agent| agent.ids.include?(identifier_id) }
      end

      def get_remote_identifiable_agent_finder(entity:)
        @remote_identiable_agent_finder_cache ||= {}
        @remote_identiable_agent_finder_cache[entity] ||= Queries::Complex::AgentsAssociatedWithEntity.new(entity: entity)
      end
    end
  end
end
