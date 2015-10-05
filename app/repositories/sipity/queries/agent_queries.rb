module Sipity
  module Queries
    module AgentQueries
      def get_identifiable_agent_for(entity:, identifier_id:, repository: self)
        identifiable_agent = repository.work_collaborators_for(work: entity, identifier_id: identifier_id).first ||
          remote_identifiable_agent_for(entity: entity, identifier_id: identifier_id) || identifier_id
        PowerConverter.convert(identifiable_agent, to: :identifiable_agent)
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
