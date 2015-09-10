module Sipity
  module Services
    module Queries
      # Responsible for exposing the given entity's agent permissions via aggregation of
      # the local role and expanded identifier_id.
      #
      # @todo I need to be able to get the identifiers associated with the given role
      # @see Sipity::Queries::ProcessingQuery#scope_users_for_entity_and_roles
      class AgentsAssociatedWithEntity
        def initialize(entity:, **keywords)
          self.entity = entity
          self.role_and_identifier_ids_finder = keywords.fetch(:role_and_identifier_ids_finder) { default_role_and_identifier_ids_finder }
          self.agents_finder = keywords.fetch(:agents_finder) { default_agents_finder }
          self.aggregator = keywords.fetch(:aggregator) { default_aggregator }
        end

        def each
          return enum_for(:each) unless block_given?
          aggregated_data.each { |datum| yield(datum) }
        end

        private

        def aggregated_data
          role_and_identifier_ids = find_all_roles_and_associated_identifiers
          agents = agents_finder.call(identifiers: role_and_identifier_ids.map(&:identifier_id))
          aggregator.call(role_and_identifier_ids: role_and_identifier_ids, agents: agents)
        end

        attr_reader :entity
        def entity=(input)
          @entity = Conversions::ConvertToProcessingEntity.call(input)
        end

        def find_all_roles_and_associated_identifiers
          role_and_identifier_ids_finder.call(entity: entity)
        end

        attr_accessor :role_and_identifier_ids_finder
        def default_role_and_identifier_ids_finder
          RoleIdentifierFinder.method(:all_for)
        end

        attr_accessor :agents_finder
        def default_agents_finder
          require 'cogitate/client' unless defined?(Cogiate::Client)
          Cogitate::Client.method(:request)
        end

        attr_accessor :aggregator
        def default_aggregator
          Aggregator.method(:aggregate)
        end

        # @todo Extract to a proper first class finder
        module RoleIdentifierFinder
          def self.all_for(entity:, role: nil)
            entity = Conversions::ConvertToProcessingEntity.call(entity)
            strategy_roles = Models::Processing::StrategyRole.arel_table
            entity_responsibilities = Models::Processing::EntitySpecificResponsibility.arel_table
            strategy_responsibilities = Models::Processing::StrategyResponsibility.arel_table

            entity_specific_select_manager = strategy_role_projection_for(
              entity: entity, arel_table: entity_responsibilities, role: role,
              permission_grant_level: Models::Processing::Actor::ENTITY_LEVEL_ACTOR_PROCESSING_RELATIONSHIP
            ).join(entity_responsibilities).on(
              entity_responsibilities[:strategy_role_id].eq(strategy_roles[:id])
            ).where(
              entity_responsibilities[:entity_id].eq(entity.id)
            )

            strategy_specific_select_manager = strategy_role_projection_for(
              entity: entity, arel_table: strategy_responsibilities, role: role,
              permission_grant_level: Models::Processing::Actor::STRATEGY_LEVEL_ACTOR_PROCESSING_RELATIONSHIP
            ).join(strategy_responsibilities).on(
              strategy_responsibilities[:strategy_role_id].eq(strategy_roles[:id])
            ).where(
              strategy_roles[:strategy_id].eq(entity.strategy_id)
            )

            strategy_roles_select_manager = entity_specific_select_manager.union(strategy_specific_select_manager)

            Models::Processing::StrategyRole.from(
              strategy_roles.create_table_alias(strategy_roles_select_manager, strategy_roles.table_name)
            ).all
          end

          def self.strategy_role_projection_for(entity:, arel_table:, permission_grant_level:, role: nil)
            strategy_roles = Models::Processing::StrategyRole.arel_table
            roles = Models::Role.arel_table

            select_manager = strategy_roles.project(
              strategy_roles[:role_id].as('role_id'),
              roles[:name].as('role_name'),
              arel_table[:identifier_id],
              Arel.sql(entity.id.to_s).as("entity_id"),
              Arel.sql("'#{permission_grant_level}'").as('permission_grant_level')
            ).join(roles).on(
              strategy_roles[:role_id].eq(roles[:id])
            )
            return select_manager if role.nil?
            role = Conversions::ConvertToRole.call(role)
            select_manager.where(roles[:id].eq(role.id))
          end
          private_class_method :strategy_role_projection_for
        end

        # :nodoc:
        module Aggregator
          def self.aggregate(*)
          end
        end
      end
    end
  end
end
